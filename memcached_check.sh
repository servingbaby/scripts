#!/bin/bash
# memcached_check.sh v1.0
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

MC_IP=127.0.0.1
MC_PORT=11211
MC_LOG=/var/log/memcached_stats.log

DTS=`date -R`

/usr/bin/nc -w 5 -i 1 $MC_IP $MC_PORT << EOF | grep -q ^END
stats
quit
EOF

if [ $? -eq 0 ]; then
  echo "[$DTS] OK" >> $MC_LOG
else
  echo "[$DTS] FAILED" >> $MC_LOG
fi

exit 0

