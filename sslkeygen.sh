#!/bin/bash
# sslkeygen.sh v1.0
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

if [ $# -lt 2 ]; then
  echo "This script takes 2 params"
  echo
  echo "$0 <mode> <key filename>"
  echo
  exit 1
fi

SERVER=$2

case "$1" in
  makeca)
    /usr/bin/openssl genrsa -des3 -out ca.key 4096
    /usr/bin/openssl req -new -x509 -days 1825 -key ca.key -out ca.crt
    ;;
  makekey)
    /usr/bin/openssl genrsa -des3 2048 > ${SERVER}.key.encrypted
    /usr/bin/openssl rsa -in ${SERVER}.key.encrypted -out ${SERVER}.key
    ;;
  makecsr)
    if [ ! -f ${SERVER}.key ]; then
      echo "${SERVER}.key missing, run \"$0 makekey\" first."
      exit 1
    fi
    /usr/bin/openssl req -new -key ${SERVER}.key -out ${SERVER}.csr
    ;;
  signcrt)
    if [ ! -f ca.key ] || [ ! -f ca.crt ]; then
      echo "ca.key missing, run \"$0 makeca\" first."
      exit 1
    fi
    if [ ! -f ${SERVER}.csr ]; then
      echo "${SERVER}.csr missing, run \"$0 makecsr\" first."
      exit 1
    fi
    /usr/bin/openssl x509 -req -days 1825 -in ${SERVER}.csr -CA ca.crt \
      -CAkey ca.key -set_serial 01 -out ${SERVER}.crt
    ;;
  makedh)
    /bin/dd if=/dev/urandom of=ssldh.rand count=1 2>/dev/null
    /usr/bin/openssl gendh -rand ssldh.rand 512 > ${SERVER}.dh
    ;;
  makepem)
    if [ ! -f ${SERVER}.key ]; then
      echo "${SERVER}.key missing, run \"$0 makekey\" first."
      exit 1
    fi
    if [ ! -f ${SERVER}.crt ]; then
      echo "${SERVER}.crt missing, obtain from CA or run \"$0 signcrt\" first."
      exit 1
    fi
    cat ${SERVER}.key > ${SERVER}.pem
    cat ${SERVER}.crt >> ${SERVER}.pem
    ;;
  *)
    echo
    echo $"Usage: $0 {makeca|makekey|makecsr|signcrt|makedh|makepem} <key filename>"
    echo
    exit 2
esac

exit 0

