#!/bin/bash

SUBDIR=compressed
ORIGINALSDIR=originals
FILES=`ls *| grep -i jpg`

echo "Press enter to compress the following files:"
echo $FILES
read -p ""
mkdir -p $SUBDIR
mkdir -p $ORIGINALSDIR

for i in $FILES
do
    BASE_NAME=`basename $i .$TGT_EXT`
    NEW_NAME=$SUBDIR"/"$BASE_NAME".JPG"
    echo convert -quality 85 $i $NEW_NAME
    convert -quality 85 $i $NEW_NAME
    mv $i $ORIGINALSDIR
done

mv $SUBDIR/* .
rm -rf $SUBDIR
du -h


