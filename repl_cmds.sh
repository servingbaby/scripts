# repl_cmds.sh v1.0
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

# if resize (via xterm) is not available

alias tsize='shopt -s checkwinsize;COLUMNS=$(tput cols);LINES=$(tput lines);export COLUMNS LINES;echo -e "COLUMNS=$COLUMNS;\nLINES=$LINES;\nexport COLUMNS LINES;"'

# if netcat is not available (requires --enable-net-redirections compiled in
# with bash, works on RHEL/CentOS/Fedora but not Ubuntu/Debian

function nctzv() { [ $# -eq 2 ] && (timeout 3 bash -c "echo >/dev/tcp/$1/$2" && echo "Connection to $1 port $2/tcp succeeded" || echo "Connection to $1 port $2/tcp failed"); }

function ncuzv() { [ $# -eq 2 ] && (timeout 3 bash -c "echo >/dev/udp/$1/$2" && echo "Connection to $1 port $2/udp succeeded" || echo "Connection to $1 port $2/udp failed"); }

