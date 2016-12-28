#!/usr/bin/env bash
#
# Search for a named library linked in to an object (binary)
#
# Input: <name of library to find> - suffix will be stripped
# Output: comma delimited (object,library,filematch)

# strip everything after the first . (libfoo.so.1.2.3 -> libfoo)
LIB="${1%%.*}"
if [[ -z "${LIB}" ]]; then
  echo "Empty string, aborting."
  exit 1
else
  # use STDOUT in case script output is being saved to a file
  (>&2 echo -e "Search: ${LIB} (status: \"watch -n 10 kill -HUP $$\" in another terminal)")
fi

# we'll populate _CDIR and _COBJ in looping stanzas, this goes to STDOUT
_CDIR=""
_COBJ=""
function hupcstat() {
  (>&2 echo "${_CDIR}: ${_COBJ}")
}
trap hupcstat SIGHUP

# params: <name> <colon seperated dirs to search>
# output: <object>,<linked name>,<found location>
function searchlib() {
  WHAT="${1}"
  WHERE="${2}"
  OLDIFS=${IFS}
  IFS=:
  # do not be tempted to quote the array, breaks IFS work later
  for SEARCHDIR in ${WHERE}; do
    if [[ -d "${SEARCHDIR}" && ! -h "${SEARCHDIR}" ]]; then
      _CDIR="${SEARCHDIR}"
      # this can beat up the system depending, use ionice to tame it
      # rather than use '-printf "%p:"' to find we remove dupes first
      # the -L follows symlinks, so with -type f and sort we weed out trash
      # exclude kernel modules and firmware to reduce wasted time
      OBJS=$(ionice -c 2 -n 4 find -L "${SEARCHDIR}" \
             -not \( -path /lib/modules -prune \) \
             -not \( -path /usr/lib/modules -prune \) \
             -not \( -path /lib/firmware -prune \) \
             -not \( -path /usr/lib/firmware -prune \) \
             -type f | sort -u | tr '\n' ':')
      for OBJ in ${OBJS}; do
        # ldd "not a dynamic executable" is faster than using 'file'
        _COBJ="${OBJ}"
        ldd "${OBJ}" 2>/dev/null | grep -i "${WHAT}" | \
          awk '{print $1 "," $3}' | \
          xargs -I '{}' printf "${OBJ},%s\n" '{}'
      done  
    fi
  done
  IFS=${OLDIFS}
}

# Search for binaries in $PATH first
searchlib "${LIB}" "${PATH}"

# Search all well-known (depends on distro) library paths
LDP="/lib:/usr/lib:/usr/local/lib:/lib32:/lib64:/usr/lib32:/usr/lib64:/usr/local/lib32:/usr/local/lib64:/lib/i386-linux-gnu:/lib/x86_64-linux-gnu:/usr/i686-linux-gnu/lib32:/usr/i686-linux-gnu/lib64:/usr/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu:/usr/local/lib/x86_64-linux-gnu:/usr/x86_64-linux-gnu/lib64:${LD_LIBRARY_PATH}"
searchlib "${LIB}" "${LDP}"

exit 0

