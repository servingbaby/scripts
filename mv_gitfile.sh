#!/bin/bash
 
# Given a file in a repo, create a series of git patches to import into
# another repo
#
# $1 == name of file (no leading path -- will be checked ./<file>)
 
RSRC=$1
PDIR=/tmp/gitmrg
 
if [ ! -d ${PDIR} ]; then
  echo "Creating ${PDIR} ..."
  mkdir -p ${PDIR}
else
  echo "Cleaning ${PDIR} ..."
  rm -i ${PDIR}/*
fi
 
if [ ! -f "./${RSRC}" ]; then
  echo "Bad input - must be in the git directory and name the file"
  exit 1
fi
 
_INIT=$(git rev-list --parents HEAD ${RSRC} | egrep "^[a-f0-9]{40}$")
git format-patch -1 -o ${PDIR} --start-number 0 ${_INIT} ${RSRC}
git format-patch -o ${PDIR} --start-number 1 ${_INIT}..HEAD ${RSRC}
 
echo "Next steps:"
echo " cd /destination/repo"
echo " git am ${PDIR}/*.patch"
echo " git push"
 
exit 0
