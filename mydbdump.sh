#!/bin/bash
# mydbdump.sh v1.0
#
# Copyright (c) 2009 <troyengel>
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

# SIMPLE MySQL backup: dumps a complete database, keeping 7 days worth
# of backups in rotation. run nightly.
#
# Ensure you have a privileged login cookied for the user who will
# run this script. E.g.:
#
# /root/.my.cnf:
# [client]
# user=root
# password=p@ssw0rd

MYD_BDIR=/opt/backups/database
MYD_DUMP=/usr/bin/mysqldump
MYD_BZ2=/usr/bin/bzip2

# get the day of week, 1 = Monday
DOW=`date "+%u"`

# we overwrite the old weekday's backup
MYD_BLOG=$MYD_BDIR/db-backup.log.${DOW}
MYD_BFILE=$MYD_BDIR/db-backup.sql.${DOW}

# the real export procedure
$MYD_DUMP -A --opt 1>$MYD_BFILE 2>$MYD_BLOG

# erase old bz2 files
if [ -f "${MYD_BFILE}.bz2" ]; then
  rm -f "${MYD_BFILE}.bz2"
fi
if [ -f "${MYD_BLOG}.bz2" ]; then
  rm -f "${MYD_BLOG}.bz2"
fi

# compress our files to save some space
$MYD_BZ2 $MYD_BFILE
$MYD_BZ2 $MYD_BLOG

exit 0

