#!/bin/bash
#
# Search all binaries in $PATH for missing shared libs

IFS=:
for BINDIR in ${PATH}; do
  BINS=$(find "${BINDIR}" -type f -printf "%p:")
  for BIN in ${BINS}; do
    ldd "${BIN}" 2>/dev/null | grep -i "not found" | cut -d ' ' -f1 | \
      xargs -I '{}' printf "${BIN},%s\n" '{}'
  done
done

