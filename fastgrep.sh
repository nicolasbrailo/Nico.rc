#!/bin/bash

INDEX_DIRS="client sandbox src test www"
EXCLUDE_DIRS="www/static"


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


#####################################################
# Cache building functions
#####################################################

# Base regex to ignore: all the binary files and the versioning files
BASE_IGNORE_REGEX='\.git|\.svn|\.jpg|\.png|\.pdf|\.doc|\.ttf|\.pyc'

# Lists all the file in the project, filtering out the binaries and the
# set of user defined uninteresting files
function list_interesting_files() {
    for dir in $INDEX_DIRS; do
        # find all the files in the interesting dirs
        #       | grep out the file types we don't care about
        #       | get file info for each one
        #       | grep those that contain text
        find $dir -type f | egrep -v "$BASE_IGNORE_REGEX|$EXCLUDE_DIRS" \
                | xargs file | grep 'text' | awk -F':' '{print $1}'
    done
}

# Builds a new cache file from all the files considered "interesting"
# by the 'list_interesting_files' function
function rebuild_cache() {
    grepcache_file=$1
    echo '' > $grepcache_file
    for file in `list_interesting_files`; do
        cat $file | awk "{print \"$file \"\$0}" >> $grepcache_file
    done
}

#####################################################
# Grep wrapping
#####################################################

# Gets from an index file all the project files which mach a needle
function get_files_for() {
    cache_file_path=$1
    needle=$2

    # Get a basedir to print absolute paths
    basedir=`dirname $cache_file_path`
    grep -nri $needle $cache_file_path \
        | awk -F':' '{print $2}' | awk "{print \"$basedir/\"\$1}"
}

# Gets all the *unique* files which mach a string search. This is needed
# so we don't have to grep again more than once
function get_unique_files_for() {
    get_files_for $1 $2 | sort | uniq
}

# Wrap grep: get a list of file matches from an index, then grep each file
# again to get the real matches
function wraped_grep() {
    cache_file_path=$1
    needle=$2
    files=`get_unique_files_for $cache_file_path $needle`

    # If we found no files we want to just exit
    if [ ${#files} -gt 1 ]; then
        grep -nri $needle $files
    fi
}


#####################################################
# User interface
#####################################################


GREPCACHE_BASE_FILE=.grepcache

while getopts "hr" opt; do
    case "$opt" in
        h) echo -ne "$0 is a simple grep wrapper to speed up searches in a large"
           echo -ne " set of files. If you find yourself running 'grep -r *' and"
           echo -ne " then waiting more than 10 seconds, $0 will help you speed"
           echo -ne " up your searches.\n\n"
           echo "$0 [run options|search pattern]"
           echo ""
           echo "Run options:"
           echo "  -h: This help"
           echo "  -r: Rebuild cache"
           echo ""
           exit ;;
        r) echo "Rebuilding cache...";
           rebuild_cache ./$GREPCACHE_BASE_FILE
           exit ;;
    esac
done


GREPCACHE_FILE=`find_file_in_tree $GREPCACHE_BASE_FILE`

if [ "${#GREPCACHE_FILE}" -lt 2 ]; then
    echo "Cache file $GREPCACHE_BASE_FILE not found."
    echo "Run $0 -r in the root of the project."
    exit
fi

wraped_grep GREPCACHE_FILE $1

