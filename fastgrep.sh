#!/bin/bash

# About fastgrep: simple grep wrapper to speed up grep'ing through a large
# set of file, for example a more or less big programming project. The idea
# behind it is simple, just concat all the files in the project in a giant
# blob (with a reference back to the original file), then grep that blob 
# instead of greping through each file in the project; this way we save most
# of the disk lookups + we can exclude greping through files which we already
# know we won't care.
# Some quick tests show that for ~10 secs greps we can go down to ~1 sec. For
# bigger projects the speedup might be bigger.
# 
# TODO: fastgrep will print absolute paths. This is nice when you whan to run
# it from any directory in your project but it would be good to have a way to
# print rel paths instead.
#
# TODO: Cleanup the getopts part, it's very ugly

#####################################################
# Cache building functions
#####################################################

# Base regex to ignore: all the binary files and the versioning files
BASE_IGNORE_REGEX='\.git|\.svn|\.jpg|\.png|\.pdf|\.doc|\.ttf|\.pyc'

# Lists all the file in the project, filtering out the binaries and the
# set of user defined uninteresting files
function list_interesting_files() {
    dirs_to_check=$1
    exclude_pattern=$2

    if [ ${#dirs_to_check} -eq 0 ]; then
        dirs_to_check=`ls .`
    fi

    if [ ${#exclude_pattern} -gt 1 ]; then
        pattern="$BASE_IGNORE_REGEX|$exclude_pattern";
    else
        pattern="$BASE_IGNORE_REGEX";
    fi

    for dir in $dirs_to_check; do
        # find all the files in the interesting dirs
        #       | grep out the file types we don't care about
        #       | get file info for each one
        #       | grep those that contain text
        find $dir -type f | egrep -v "$pattern" \
                | xargs file | grep 'text' | awk -F':' '{print $1}'
    done
}

# Builds a new cache file from all the files considered "interesting"
# by the 'list_interesting_files' function
function rebuild_cache() {
    grepcache_file=$1
    dirs_to_check=$2
    exclude_pattern=$3

    echo '' > $grepcache_file
    for file in `list_interesting_files $dirs_to_check $exclude_pattern`; do
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
    grep -nri "$needle" $cache_file_path \
        | awk -F':' '{print $2}' | awk "{print \"$basedir/\"\$1}"
}

# Gets all the *unique* files which mach a string search. This is needed
# so we don't have to grep again more than once
function get_unique_files_for() {
    get_files_for "$1" "$2" | sort | uniq
}

# Wrap grep: get a list of file matches from an index, then grep each file
# again to get the real matches
function wraped_grep() {
    cache_file_path=$1
    needle="$2"
    files=`get_unique_files_for $cache_file_path "$needle"`

    # If we found no files we want to just exit
    if [ ${#files} -gt 1 ]; then
        grep -nri "$needle" $files
    fi
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
    config_path=$5

    if [ "${#new_idx_dirs}" -eq 0 ]; then
        new_idx_dirs=$old_idx_dirs
    fi

    if [ "${#new_excl_ptn}" -eq 0 ]; then
        new_excl_ptn=$old_excl_ptn
    fi

    echo "INDEX_DIRS=\"$new_idx_dirs\"" > $config_path
    echo "EXCLUDE_PATTERN=\"$new_excl_ptn\"" >> $config_path
}

#####################################################
# User interface
#####################################################

INDEX_DIRS=""
EXCLUDE_PATTERN=""

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
while getopts "chr" opt; do
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
           echo "  -c: Configure cache (eg set exclude patterns)" >&2
           echo "" >&2
           echo "Tip: Adding this to .bashrc is very helpful:" >&2
           echo "    function fastgrep(){ $0 \"\$@\" | grep \"\$@\"; }" >&2
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
           rebuild_config "$INDEX_DIRS" "$new_dirs_to_index" \
                          "$EXCLUDE_PATTERN" "$new_exclude_pattern" \
                          $GREPCACHE_CONFIG_BASE_FILE
           echo "Wrote config file, you should now run $0 -r to rebuild the cache" >&2
           exit ;;
        r) echo "Rebuilding cache..." >&2;
           rebuild_cache ./$GREPCACHE_BASE_FILE $INDEX_DIRS $EXCLUDE_PATTERN
           exit ;;
    esac
done

if [ "${#GREPCACHE_FILE}" -lt 2 ]; then
    echo "Cache file $GREPCACHE_BASE_FILE not found." >&2
    echo "Run $0 -r in the root of the project." >&2
    exit
fi

wraped_grep $GREPCACHE_FILE "$@"

