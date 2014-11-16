#!/bin/bash

# Action logfile
ACTLOG="/tmp/test_logact.log"
[ -f ${ACTLOG} ] && rm ${ACTLOG}

# Run action, log output, return exit code
# - passing in 'sed' should be avoided
# - functions can only return 0..254
# -- set a global to check as needed
_ACTRET=0
function logact() {
  local ACTION
  ACTION="$*"
  ${ACTION} 2>&1 | tee -a ${ACTLOG}
  _ACTRET=${PIPESTATUS[0]}
  return ${_ACTRET}
}

# Zero return test
logact echo "grep -l localhost /etc/hosts"
logact grep -l localhost /etc/hosts
logact echo -e "Direct: $?  Global: $_ACTRET\n"

# Non-zero return test
logact echo "grep -l ZlocalhostZ /etc/hosts"
logact grep -l ZlocalhostZ /etc/hosts
logact echo -e "Direct: $?  Global: $_ACTRET\n"

exit 0
