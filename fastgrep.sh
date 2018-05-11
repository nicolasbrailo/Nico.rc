#!/bin/bash

HOW_DOES_IT_WORK="""
About fastgrep: simple grep wrapper to speed up grep'ing through a large
set of files, eg a project with a few 100 or 1000 files. The concept is
simple: concat all the files in the project in a giant blob (with a 
reference back to the original file), then grep that blob instead of greping
through each file in the project; this most of the disk lookups are avoided
and we know exactly which files need to be grep'ed. Grepping again in the
files found in the cache means no false positives. False negatives are
possible with stale caches, so regular updating is recommended.

Running some tests on an average sized project yielded a speedup from
about 10 seconds to 1 second, whereas for a large project (and index file
of around 200 MB) the speedup was from 3 minutes to around 14 seconds.
Please note these are anecdotical times and not a benchmark.
"""

#####################################################
# Cache building functions
#####################################################

# Base regex to ignore: all the binary files and the versioning files
BASE_IGNORE_REGEX='\.git|\.svn|\.jpg|\.png|\.pdf|\.doc|\.ttf|\.pyc'

# Lists all the file in the project, filtering out the binaries and the
# set of user defined uninteresting files
function list_interesting_files() {
    dirs_to_check="$1"
    exclude_pattern="$2"
    include_pattern="$3"

    if [ ${#dirs_to_check} -eq 0 ]; then
        dirs_to_check=`ls .`
    fi

    if [ ${#exclude_pattern} -gt 1 ]; then
        ex_pattern="$BASE_IGNORE_REGEX|$exclude_pattern";
    else
        ex_pattern="$BASE_IGNORE_REGEX";
    fi

    if [ ${#include_pattern} -gt 1 ]; then
        in_pattern="$include_pattern";
    else
        in_pattern=".";
    fi

    for dir in $dirs_to_check; do
        # find all the files in the interesting dir
        #       | include only the files we do care about
        #       | grep out the file types we don't care about
        #       | get file info for each one (*)
        #       | accept only those that have a content of type text
        #       | print the file name
        # (*) file's stderr is ignored because the list of files might be
        # empty, which makes file complain with an ugly error that might
        # puzzle users.
        find $dir -type f \
                | egrep "$in_pattern" \
                | egrep -v "$ex_pattern" \
                | xargs file 2>/dev/null \
                | grep 'text' \
                | awk -F':' '{print $1}'
    done
}

# Builds a new cache file from all the files considered "interesting"
# by the 'list_interesting_files' function
function rebuild_cache() {
    grepcache_file="$1"
    dirs_to_check="$2"
    exclude_pattern="$3"
    include_pattern="$4"

    echo '' > $grepcache_file
    for file in `list_interesting_files "$dirs_to_check" "$exclude_pattern" "$include_pattern"`; do
        cat $file | awk "{print \"$file \"\$0}" >> $grepcache_file
    done
}

#####################################################
# Grep wrapping
#####################################################

# Gets from an index file all the project files which mach a needle
function get_files_for() {
    cache_file_path=$1
    needle="$2"

    # Get a basedir to print absolute paths
    basedir=`dirname $cache_file_path`
    grep --text -i "$needle" $cache_file_path | awk "{print \"$basedir/\"\$1}"
}

# Gets all the *unique* files which mach a string search. This is needed
# so we don't have to grep again more than once
function get_unique_files_for() {
    get_files_for "$1" "$2" | sort | uniq
}

# Wrap grep: get a list of file matches from an index, then grep each file
# again to get the real matches
function wrapped_grep() {
    cache_file_path=$1
    needle="$2"
    files=`get_unique_files_for $cache_file_path "$needle"`

    # If we found no files we want to just exit
    if [ ${#files} -gt 1 ]; then
        # To get the retval from grep we use the idiom 
        #    output=`cmd` && echo $output
        # That way if cmd fails, $? has its retval

        # -H = with filename
        # -n = include line num
        # -i = case insensitive
        # awk: make it vim friendly (explanation below)
        # sed: replace a long path with PWD
        matches=`grep -Hni "$needle" $files` && \
            echo "$matches" \
            | awk -F ':' '{print $1" +"$2"\t" substr($0, index($0, $3))}' \
            | sed "s#$PWD#.#g"

        # It's possible that we got from the index a file that doesn't exist
        # anymore: this will happen if a file has been moved and the cache is
        # stale. We should tell the user to refresh the cache.
        if [ $? -ne 0 ]; then
            echo "Looks like grep failed to run: you probably have a stale cache."
            echo "Try refreshing your cache with '$0 -r' on your project's root."
        fi

    fi

    # awk format explained:
    # Assuming the output of grep will be something like
    #   /path/to/file:line_nr:line w/matched expression, possibly including :'s
    # Then, for -F':' (ie separator = ':')
    #   $1 = /path/to/file
    #   $2 = line_nr
    #   $3-NF = We don't know, since the matched line may include ':'s too
    # Then, the format:
    #   $1" +"$2"\t" substr($0, index($0, $3))}'
    # Is the same as:
    #   /path/to/file +line_nr substr($0, index($0, $3))
    # substr($0, index($0, $3)) is the string from field $3 to NR. Check
    # man awk for documentation on substr and index.
}


#####################################################
# Random stuff
#####################################################

# Given a file name, will iterate up the directory tree until
# the file is found
function find_file_in_tree() {
    file=$1
    dir=`pwd`
    while [ ${#dir} -gt 1 ]; do
        if [ -e $dir/$file ]; then
            echo "$dir/$file";
            break;
        fi
        dir=`dirname $dir`
    done
}

# Write a new config file
function rebuild_config() {
    old_idx_dirs=$1
    new_idx_dirs=$2
    old_excl_ptn=$3
    new_excl_ptn=$4
    old_incl_ptn=$5
    new_incl_ptn=$6
    config_path=$7

    if [ "${#new_idx_dirs}" -eq 0 ]; then
        new_idx_dirs=$old_idx_dirs
    fi

    if [ "${#new_excl_ptn}" -eq 0 ]; then
        new_excl_ptn=$old_excl_ptn
    fi

    if [ "${#new_incl_ptn}" -eq 0 ]; then
        new_incl_ptn=$old_incl_ptn
    fi

    echo "INDEX_DIRS=\"$new_idx_dirs\"" > $config_path
    echo "EXCLUDE_PATTERN=\"$new_excl_ptn\"" >> $config_path
    echo "INCLUDE_PATTERN=\"$new_incl_ptn\"" >> $config_path
}

#####################################################
# User interface
#####################################################

INDEX_DIRS=""
EXCLUDE_PATTERN=""
INCLUDE_PATTERN=""

GREPCACHE_CONFIG_BASE_FILE=.grepcacheconfig
GREPCACHE_CONFIG_FILE=`find_file_in_tree $GREPCACHE_CONFIG_BASE_FILE`

GREPCACHE_BASE_FILE=.grepcache
GREPCACHE_FILE=`find_file_in_tree $GREPCACHE_BASE_FILE`


# If available load the config file
if [ "${#GREPCACHE_CONFIG_FILE}" -gt 2 ]; then
    source $GREPCACHE_CONFIG_FILE
fi

# We write everything to stderr so we can define an alias like 
# fastgrep $@|grep $@
# This keeps the highlighting as the user would expect
while getopts "hclr" opt; do
    case "$opt" in
        h) echo -ne "$0 is a simple grep wrapper to speed up searches in a large" >&2
           echo -ne " set of files. If you find yourself running 'grep -r *' and" >&2
           echo -ne " then waiting more than 10 seconds, $0 will help you speed" >&2
           echo -ne " up your searches.\n\n" >&2
           echo "$0 [run options|search pattern]" >&2
           echo "" >&2
           echo "Run options:" >&2
           echo "  -h: This help" >&2
           echo "  -r: Rebuild cache" >&2
           echo "  -l: List interesting files (useful to verify config)" >&2
           echo "  -c: Configure cache (eg set exclude patterns)" >&2
           echo "" >&2
           echo $HOW_DOES_IT_WORK >&2
           echo "" >&2
           echo "Tip: Adding this to .bashrc is very helpful:" >&2
           echo "    function fastgrep(){ $0 \"\$@\" | grep -i \"\$@\"; }" >&2
           echo "This way fastgrep will be available in any directory with colour highlighting" >&2
           echo "" >&2
           exit ;;
        c) echo "Reconfiguring cache options..." >&2
           echo -n "Type a space separated list of the directories to " >&2
           echo "index, then enter [$INDEX_DIRS]:" >&2
           echo -n " > " >&2
           read new_dirs_to_index
           echo "Type a grep style exclusion pattern, then enter [$EXCLUDE_PATTERN]:" >&2
           echo -n " > " >&2
           read new_exclude_pattern
           echo "Type a grep style inclusion pattern, then enter [$INCLUDE_PATTERN]:" >&2
           echo -n " > " >&2
           read new_include_pattern
           rebuild_config "$INDEX_DIRS" "$new_dirs_to_index" \
                          "$EXCLUDE_PATTERN" "$new_exclude_pattern" \
                          "$INCLUDE_PATTERN" "$new_include_pattern" \
                          $GREPCACHE_CONFIG_BASE_FILE
           echo "Wrote config file, you should now run $0 -r to rebuild the cache" >&2
           exit ;;
        l) echo "Listing interesting files..." >&2;
           list_interesting_files "$INDEX_DIRS" "$EXCLUDE_PATTERN" "$INCLUDE_PATTERN"
           exit ;;
        r) echo "Rebuilding cache..." >&2;
           rebuild_cache ./$GREPCACHE_BASE_FILE "$INDEX_DIRS" "$EXCLUDE_PATTERN" "$INCLUDE_PATTERN"
           exit ;;
    esac
done

if [ "${#GREPCACHE_FILE}" -lt 2 ]; then
    echo "Cache file $GREPCACHE_BASE_FILE not found." >&2
    echo "Run $0 -r in the root of the project." >&2
    exit
fi

wrapped_grep $GREPCACHE_FILE "$@"

