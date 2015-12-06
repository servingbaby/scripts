#!/bin/bash
# addExifDate.sh
#
# Requires "jhead" (yum/apt-get/pacman install jhead)
#
# a) add EXIF Date/Time headers to JPG files missing it
# b) update on-disk Date/Time to just added EXIF header
 
DTS=""
if [[ $# -ne 1 ]]; then
  echo "Usage:  $0 <date/time stamp>"
  echo "Format: YYYY:mm:dd-HH:MM:SS"
  exit 1
else
  DTS="$1"
fi

for file in *.jpg *.jpeg *.JPG *.JPEG; do
  if [[ ! -e "${file}" ]]; then
    continue
  fi
  JPGDT=$(jhead "${file}" | grep "Date/Time")
  JPGFC=$(jhead "${file}" | grep -c "Date/Time")
  if [[ ${JPGFC} -gt 1 ]]; then
    echo "Too many Date/Time results, skipping ${file}"
    continue
  elif [[ ${JPGFC} -eq 0 ]] || [[ "X${JPGDT}" == "X" ]]; then
    echo "No valid Date/Time, adding to ${file}"
    jhead -q -mkexif "${file}"
    jhead -q -ts"${DTS}" "${file}"
    jhead -q -ft "${file}"
  else
    echo "Existing Date/Time, skipping ${file}"
    continue
  fi
done

