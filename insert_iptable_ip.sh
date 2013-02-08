#!/bin/bash
# insert_iptable_ip.sh v1.0
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

# given an chain, IP/NM and interface insert that IP as an accept into the
# chain as the next to last rule before global DROP; for instance give
# chain "hosts_allow":
#
# iptables -nL hosts_allow:
#  Chain hosts_allow (1 references)
#  target     prot opt source       destination
#  ACCEPT     all  --  1.2.3.4/28   0.0.0.0/0
#  ACCEPT     all  --  4.3.2.1/26   0.0.0.0/0
#  ACCEPT     all  --  5.6.7.8/27   0.0.0.0/0
#  ACCEPT     all  --  8.7.6.5/24   0.0.0.0/0
#  ACCEPT     all  --  2.4.6.8/24   0.0.0.0/0
#  DROP       all  --  0.0.0.0/0    0.0.0.0/0
#
# example: ./insert_iptable_ip.sh hosts_allow 1.3.5.7/32 eth0

if [ `id -u` -ne 0 ]; then
  echo "Must be root, exiting."
  exit 1
fi

if [ $# -ne 3 ]; then
  echo "Usage:   $0   "
  echo "Example: $0 hosts_allow 1.3.5.7/32 eth0"
  exit 2
fi

T_CHAIN=$1
T_IP=$2
T_INT=$3

# the chain list has two extra lines, subtract those
C_NUM=`iptables -nL ${T_CHAIN} | wc -l`
C_NUM=$(($C_NUM-2))

# insert the IP as the last number (iptables is 1-based) which will push
# the final global DROP down one line
iptables -I ${T_CHAIN} ${C_NUM} -i ${T_INT} -s ${T_IP} -j ACCEPT

exit 0

