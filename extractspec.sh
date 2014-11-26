#!/bin/bash
#
# read all .src.rpm and extract the .spec
# bsdtar is part of libarchive (http://libarchive.org/)

for RPM in ./*.src.rpm; do
  VER=${RPM%.src.rpm}
  bsdtar -xOf "${RPM}" \*.spec > "./${VER}.spec"
done

exit 0
