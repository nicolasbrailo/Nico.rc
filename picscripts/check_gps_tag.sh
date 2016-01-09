find . | egrep -i ".jpg$" | while read -d $'\n' fname
do
    if [ `identify -verbose "$fname" | egrep "GPSL" | wc -l` -eq 4 ];
    then
        true;
    else
        echo "$fname missing exif";
    fi
done
