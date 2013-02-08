#!/bin/bash
# normalizeJPEG.sh v1.0
#
# Copyright (c) 2012 <troyengel>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# requires "jhead" (yum/apt-get install jhead)
# normalize JPG files based on their EXIF header - handy for loads of pics
# taken with different cameras (several phones, e.g.) that store the EXIF
# dates in different formats and name the files differently.
#
# Result: IMG_YYYYMMDD_HHMMSS.jpg
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
  elif [ "X${JPGDT}" == "X" ]; then
    echo "Empty Date/Time."
    continue
  else
      BASE=`echo $JPGDT | awk '{ printf("%s %s",$3,$4) }' | sed -e 's/\([0-9][0-9]\).\([0-9][0-9]\).\([0-9][0-9]\) \([0-9][0-9]\).\([0-9][0-9]\).\([0-9][0-9]\)/\1-\2-\3 \4:\5:\6/'`
      BASE=`date -d "$BASE" +"IMG_%Y%m%d_%H%M%S"`
      if [ ! -e "${BASE}.jpg" ]; then
        echo "New file: ${BASE}.jpg"
        mv "$file" "${BASE}.jpg"
        jhead -ft "${BASE}.jpg"
        jhead -dsft "${BASE}.jpg"
      fi
  fi
done

