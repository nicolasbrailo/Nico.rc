#!/bin/bash

TGT_EXT=JPG
FILES=`ls *.$TGT_EXT`

echo "Press enter to rename the following files:"
echo $FILES
read -p ""

for i in $FILES
do
    echo exiv2 -r '%Y%m%d.%H%M%S.:basename:' rename $i
    exiv2 -r '%Y%m%d.%H%M%S.:basename:' rename $i
done

