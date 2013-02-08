#!/bin/bash
# repl_links.sh v1.0
#
# Copyright (c) <year> <copyright holders>
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

# take a given directory and replace all symlinks with their real
# counterparts; replace a symlink to a file with the real file and
# a symlink to a directory with the real one.

ROOT=$1

LINKS=`find "${ROOT}" -type l -printf "%p\n"`

OLDIFS=$IFS
IFS=$'\012'

for link in ${LINKS}; do
  if [ -d "${link}" ]; then
    echo "dir: ${link}"
    mv "${link}" "${link}.sym"
    mkdir "${link}"
    cp -LcdpR "${link}.sym"/* "${link}/"
  elif [ -f ${link} ]; then
    echo "file: ${link}"
    mv "${link}" "${link}.sym"
    cp -Lcp "${link}.sym" "${link}"
  else
    echo "unknown: ${link}"
  fi
done

IFS=${OLDIFS}

