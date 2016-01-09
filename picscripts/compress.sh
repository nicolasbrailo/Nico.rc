#!/bin/bash

TGT_EXT=JPG
FILES=`ls *.$TGT_EXT`

echo "Press enter to compress the following files:"
echo $FILES
read -p ""

for i in $FILES
do
    BASE_NAME=`basename $i .$TGT_EXT`
    NEW_NAME=$BASE_NAME"_v2.JPG"
    echo convert -quality 85 $i $NEW_NAME
    convert -quality 85 $i $NEW_NAME
done

