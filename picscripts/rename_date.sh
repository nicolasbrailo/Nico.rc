#!/bin/bash

FILES=$( ls | grep -i JPG )

echo "Press enter to rename the following files:"
echo $FILES
read -p ""

for i in $FILES
do
    echo exiv2 -r '%Y%m%d.%H%M%S' rename $i
    exiv2 -r '%Y%m%d.%H%M%S' rename $i
done

