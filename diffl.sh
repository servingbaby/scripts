#!/bin/sh
diff --unchanged-line-format="" \
  --old-line-format="%dn: %L" \
  --new-line-format="%dn: %L" \
  "$1" "$2" | sort -n
