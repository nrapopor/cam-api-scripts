# ------------- SCRIPT ------------- #

#!/bin/bash
. ${0%/*}/util_functions.sh
echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ----------------------->  $1       "
echo "# \$2 ----------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# dirname path ------------->  $(dirname $0)  "
script_path
echo "# SCRIPTPATH path ---------->  ${SCRIPTPATH}  "
echo "# my name ------------------>  ${0##*/} "
echo
exit
