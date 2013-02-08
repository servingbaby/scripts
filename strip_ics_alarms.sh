#!/bin/bash
# strip_ics_alarms.sh v1.0
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

# Given an ICS input file, write a new ICS output file with all the
# alarms stripped out (BEGIN:VALARM -> END:VALARM)

if [ ! -r "$1" ]; then
  echo "Cannot read input file $1, exiting."
  exit 1
fi

INFILE=$1
OUTFILE="${INFILE}.stripped"

# create/truncate it so we can use >> later
: > "${OUTFILE}"

VERBOSE=1
READLINES=0
WROTELINES=0
EVENTCOUNT=0
ALARMCOUNT=0
GOTALARM=0

if [ ${VERBOSE} ]; then
  echo -n "Working"
fi

# preserve whitespace, don't interpret escapes
while IFS=$'\n' read -r vline; do
  READLINES=$(($READLINES+1))
  if [ ${VERBOSE} ]; then
    if [ $(($READLINES%100)) -eq 0 ]; then
      echo -n "."
    fi
  fi
  # use substring matching to avoid possible '\r' and '^M' on lines
  if [ "${vline:0:12}" == "BEGIN:VEVENT" ]; then
    EVENTCOUNT=$(($EVENTCOUNT+1))
  fi
  if [ ${GOTALARM} -ne 1 ]; then
    if [ "${vline:0:12}" != "BEGIN:VALARM" ]; then
      # don't interpret escapes while writing
      echo -E "${vline}" >> "${OUTFILE}"
      WROTELINES=$(($WROTELINES+1))
      continue
    else
      GOTALARM=1
      continue
    fi
  else
    if [ "${vline:0:10}" == "END:VALARM" ]; then
      GOTALARM=0
      ALARMCOUNT=$(($ALARMCOUNT+1))
    fi
    continue
  fi
done < "${INFILE}"

if [ ${VERBOSE} ]; then
  echo "done."
  echo "Read ${READLINES} lines"
  echo "Wrote ${WROTELINES} lines"
  echo "Found ${EVENTCOUNT} events"
  echo "Stripped ${ALARMCOUNT} alarms"
fi

exit 0

