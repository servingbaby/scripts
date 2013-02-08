# sharks_vcal.awk v1.0
#
# Copyright (c) 2006 <troyengel>
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

# Convert the Sharks "Outlook" (tab delimited) format to vCal format
# http://www.sjsharks.com/schedule/outlook.asp

# set our file separator to TAB, print out the vCal header
BEGIN {
  FS = "[t]";
  print "BEGIN:VCALENDAR";
  print "VERSION:1.0";
}

# Make a vCal UTC format out of the ugly Sharks format
# ex.: 10/5/2006 7:30:00 PM -> 20061006T023000Z
# m/d/y, h:m:s am|pm
function vCalDTS(date,time)
{
  # date reorg for mktime()
  split(date,adate,"/");
  d_ts = sprintf("%d %02d %02d",adate[3],adate[1],adate[2]);

  # time reorg for mktime()
  split(time,time1," ");
  split(time1[1],time2,":");
  hour = sprintf("%02d",time2[1]);
  #
  # do a little 12->24 hour time voodoo
  if ((tolower(time1[2]) ~ /pm/) && (hour !~ /12/))
    hour = hour + 12;
  else if ((hour ~ /12/) && (tolower(time1[2]) ~ /am/))
    hour = hour - 12;
  t_ts = sprintf("%02d %02d %02d",hour,time2[2],time2[3]);

  # make UTC time
  e_ts = mktime(d_ts " " t_ts " -");

  # add the GMT offset, accounting for daylight savings time
  # (will always be -0700 or -0800 for the Sharks schedule)
  if (tz ~ /-0700/)
    e_ts = e_ts + 25200;
  else
    e_ts = e_ts + 28800;

  # return vCal friendly format
  return (strftime("%Y%m%dT%H%M%SZ",e_ts));
}

{
  # skip the first line with column headers
  if ($1 ~ /Subject/)
    next;

  # print the easy stuff
  print "BEGIN:VEVENT";
  printf("DTSTART:%sn",vCalDTS($2,$3));
  printf("DTEND:%sn",vCalDTS($4,$5));
  printf("SUMMARY:%sn",$1);

  # home vs. away games
  if (match($1," at "))
    printf("LOCATION:%sn",substr($1,RSTART+RLENGTH));
  else
    print "LOCATION:Shark Tank";

  # print the rest of the easy stuff
  lm_dts = strftime("%Y%m%dT%H%M%S",systime());
  print "LAST-MODIFIED:" lm_dts;
  print "CLASS:PUBLIC";
  print "END:VEVENT";
}

# print out the final vCal footer
END {
  print "END:VCALENDAR";
}

