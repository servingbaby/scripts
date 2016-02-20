#!/bin/bash

# handy function to cleanly remove a PATH element
function pathdel() {
  local _PDEL=$1
  PATH=:$PATH:
  PATH=${PATH//:$_PDEL:/:}
  PATH=${PATH#:};
  PATH=${PATH%:}
  export PATH
}

pathdel /some/random/bin
echo $PATH

