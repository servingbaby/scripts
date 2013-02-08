#!/bin/bash
# xml2jph.sh v1.0
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

# Read XML from Flickr and rename corresponding files to 'taken' date
# requires xml2 and jhead RPMs
 
for file in *.xml; do
  FNAME="${file%.*}"
  if [ ! -e "${FNAME}.jpg" ]; then
    continue
  fi
  echo "Inspecting $file"
  JPGDT=`xml2 < $file | grep "@taken=" | cut -f2 -d '='`
  if [ "X${JPGDT}" == "X" ]; then
    echo "Empty Date/Time."
    continue
  else
      BASE=`date -d "$JPGDT" +"FLICKR_%Y%m%d_%H%M%S"`
      if [ ! -e "${BASE}.jpg" ]; then
        echo "New file: ${BASE}.jpg"
        mv "${FNAME}.jpg" "${BASE}.jpg"
        touch -d "${JPGDT}" "${BASE}.jpg"
        jhead -mkexif -dsft "${BASE}.jpg"
        rm -f "${file}"
      fi
  fi
done

