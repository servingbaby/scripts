#!/bin/bash
# normalizeJPEG.sh
#
# requires "jhead" (yum/apt-get install jhead)
# normalize JPG files based on their EXIF header - handy for loads of pics
# taken with different cameras (several phones, e.g.) that store the EXIF
# dates in different formats and name the files differently.
#
# Result: YYYY-MM-DD_HH-MM-SS_###.jpg (where ### is random 100-999)
# 
# This script also updates date/timestamp on disk, then reverse updates the
# EXIF header from that stamp to normalize your headers DATE/TIME field
#
# Original: http://neverfear.org/blog/view/148/Rename_all_jpeg_files_by_their_exposure_date_Bash
 
for file in *.jpg *.jpeg *.JPG *.JPEG; do
  if [ ! -e "$file" ]; then
    continue
  fi
  echo "Inspecting $file"
  JPGDT=`jhead "$file" | grep "Date/Time"`
  JPGFC=`jhead "$file" | grep "Date/Time" | wc -l`
  if [ $JPGFC -gt 1 ]; then
    echo "Found too many results for: $file"
    continue
  elif [ $JPGFC -eq 0 ]; then
    echo "No valid headers found."
    continue
  else
      BASE=`echo $JPGDT | awk '{ printf("%s %s",$3,$4) }' | sed -e 's/\([0-9][0-9]\).\([0-9][0-9]\).\([0-9][0-9]\) \([0-9][0-9]\).\([0-9][0-9]\).\([0-9][0-9]\)/\1-\2-\3 \4:\5:\6/'`
      BASE=`date -d "$BASE" +"%Y-%m-%d_%H-%M-%S"`
      RND=$[($RANDOM%899)+100]
      if [ ! -e "${BASE}_${RND}.jpg" ]; then
        echo "New file: ${BASE}_${RND}.jpg"
        mv "$file" "${BASE}_${RND}.jpg"
        jhead -ft "${BASE}_${RND}.jpg"
        jhead -dsft "${BASE}_${RND}.jpg"
      fi
  fi
done

