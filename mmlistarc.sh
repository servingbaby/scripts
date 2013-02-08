#!/bin/bash
# mmlistarc.sh v1.0
#
# Copyright (c) 2010 <troyengel>
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

# change all your mailman archive settings to private; useful if you have
# dozens of privates lists and didn’t realize that even though the list was
# locked down, the archives were left open to the world. The script is based
# on an older mailing list post by Daniel Clark:
# http://mail.python.org/pipermail/mailman-users/2007-February/055670.html

DDB=/usr/lib/mailman/bin/dumpdb
MCL=/usr/lib/mailman/bin/config_list
DBH=/var/lib/mailman/lists

echo "mlist.archive_private = 1" > /tmp/mmlistarc.dat

for direc in ${DBH}/* ; do
  if [ -f $direc/config.pck ]; then
    listname=${direc##*/}
    echo "$listname before, after"
    $DDB $direc/config.pck | grep -i archive_private
    if [ ! -f $direc/config.pck.backup ]; then
      cp -a $direc/config.pck $direc/config.pck.backup
    fi
    $MCL -i /tmp/mmlistarc.dat $listname
    $DDB $direc/config.pck | grep -i archive_private
  fi
done 

rm -f /tmp/mmlistarc.dat

exit 0

