#!/bin/bash
# jadmaker.sh v1.0
#
# Copyright (c) 2007 <troyengel>
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

# Given a J2ME midlet jarball, create a JAD for it
# Usage: ./jadmaker.sh <filename>
#
# for ii in *.jar; do ./jadmaker.sh $ii; done;

FILE=$1
if [ ! -f "${FILE}" ]; then
  echo "Input file '${FILE}' missing, exiting."
  exit 1
fi

JAD="${FILE%.*}.jad"
if [ -f "${JAD}" ]; then
  echo "${JAD} already exists, overwrite? (y/N)"
  read tmpans
  answer=$(echo "$tmpans" | tr '[:upper:]' '[:lower:]')
  if [ "$answer" != "y" ] && [ "$answer" != "yes" ]; then
    echo "Not overwriting ${JAD}, exiting."
    exit 1
  else
    rm -f "${JAD}"
  fi
fi

# unzip the internal manifest, changing line endings to our local OS
# the sed action removes blank lines, with or without spaces/tabs
unzip -aa -j -p ${FILE} "META-INF/MANIFEST.MF" | sed -e '/^[ \t]*$/d' > "${JAD}"

# generic variables
echo "MIDlet-Jar-URL: ${FILE}" >> "${JAD}"
echo "MIDlet-Info-URL: http://" >> "${JAD}"

# actual jarball size
FILESIZE=$(stat -c%s "${FILE}")
echo "MIDlet-Jar-Size: ${FILESIZE}" >> "${JAD}"

# weee
echo "Created ${JAD}."
exit 0

