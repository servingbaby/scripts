#!/bin/bash
#
# Copyright (c) 2013 <troyengel>
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

if [ $# -ne 2 ]; then
  echo "2 Parameters required: SRCDIR and LOGBASE."
  echo " Example: $0 /opt/work WORKfacldump"
  exit 1
fi

# starting tree of the filesystem to dump ACLs
SRCDIR=$1
# base filename to prepend in /var/log/facldump
LOGBASE=$2

if [ ! -d ${SRCDIR} ]; then
  echo "${SRCDIR} does not exist! Exiting."
  exit 1
fi

# some changes here could affect code, take care
LOGDIR=/var/log/facldump
DURATION_KEEP=28
DSPEC="+%Y%m%d_%H%M"
CEXT=gz

# avoid aliases, bad PATH, etc.
DT=/bin/date
GF=/usr/bin/getfacl
GZ=/bin/gzip
RM=/bin/rm
MK=/usr/bin/mkdir

# get our date/timestamp cutoff for cleanup
DATE_KEEP=$($DT --date "now - $DURATION_KEEP days" +"%Y%m%d")
# get our date/timespec to name new files
DATE_SAVE=$($DT $DSPEC)
# get the length of the above + . + extension (20130209_1106.gz = 16 e.g.)
TLEN=$((${#DATE_SAVE}+${#CEXT}+1))

# cleanup older than DURATION_KEEP by comparing the YYYMMDD in the filename
#  to the YYYYMMDD of the DATE_KEEP generated above
cleanup_older (){
  for logfile in ${LOGDIR}/${LOGBASE}.*; do
    LLEN=${#logfile}
    DTS=${logfile:(-$TLEN):8}
    if [ $DTS -lt $DATE_KEEP ]; then
      ${RM} -f ${logfile}
    fi
  done
}

create_dump (){
  ${GF} -R -p ${SRCDIR} | ${GZ} --fast > ${LOGDIR}/${LOGBASE}.$(date $DSPEC).${CEXT}
}

if [ ! -d ${LOGDIR} ]; then
  ${MK} -p ${LOGDIR}
fi

create_dump
cleanup_older

exit 0
