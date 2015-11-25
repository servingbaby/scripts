#!/bin/env bash
#
# This relaxes JNLP (i.e. DRAC5/iLO2) to enable SSLv3
# Save to ${HOME}/bin/javaws.sh and chmod+x it
#
# Automatic: in Firefox Preferences, go to the Applications tab and look
#            for "jnlp" file, reconfigure to launch this script
#
# Manual:
#  1. Launch console from DRAC webUI, get error about SSL connection
#  2. Look in /tmp for the .jnlp file it just created
#  3. javaws.sh /tmp/<name-of-jnlp-file>
#
# NOTE: jnlp file "expires" after awhile (user login has timer on it)

JWS=${HOME}/tools/java/bin/javaws
CSP=${HOME}/.java/deployment/custom.security
JDP=${HOME}/.java/deployment/deployment.properties

# override the default (ships with JRE/JDK) java.security
## this cannot be passed to the JVM via -J-D...
if [[ ! -f "${CSP}" ]] || \
   [[ $(grep -q ^jdk.tls.disabledAlgorithms= "${CSP}"; echo $?) -ne 0 ]]; then
  echo "jdk.tls.disabledAlgorithms=" >> "${CSP}"
fi

# ensure the deployment configused by javaws is also tweaked
if [[ ! -f "${JDP}" ]] || \
   [[ $(grep -q ^deployment.security.SSLv3= "${JDP}"; echo $?) -ne 0 ]]; then
  echo "deployment.security.SSLv3=true" >> "${JDP}"
fi

$JWS -J-Djava.security.properties=${CSP} "$@"
exit $?

