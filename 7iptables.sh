#!/bin/sh
# 7iptables.sh 1.0
#
# Copyright (c) 2014 <troyengel>
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

function error_exit {
  echo "Trapped a kill signal, exiting."
  exit 1
}
trap error_exit SIGHUP SIGINT SIGTERM

if [[ ! -f /etc/sysconfig/iptables ]]; then
  echo "Adding basic IPv4 iptables config (SSH access only)..."
  cat << 'EOF' > /etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
-A FORWARD -j REJECT --reject-with icmp-host-prohibited 
COMMIT
EOF
fi
 
if [[ ! -f /etc/sysconfig/ip6tables ]]; then
  echo "Adding basic IPv6 iptables config (SSH access only)..."
  cat << 'EOF' > /etc/sysconfig/ip6tables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p ipv6-icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
EOF
fi

echo "Disabling firewalld and enabline iptables/ip6tables..."
yum -y install iptables-services && ( \
 systemctl stop firewalld && systemctl disable firewalld.service; \
 systemctl start iptables.service && systemctl enable iptables.service; \
 systemctl start ip6tables.service && systemctl enable ip6tables.service
)

exit 0

