#!/bin/bash
#################################################################	
# Description:
#	Update the test with new data/status
# For usage details run updateTest.sh -h
#################################################################
export SCRIPT_TYPE=update
#defaults
. ${0%/*}/cam_setenv.sh
#functions
. ${0%/*}/cam_functions.sh

#reset some defaults
export TEST_NAME=

AUTHOR=${AUTHOR_DEFAULT}
REF_ID=
MESSAGE=
STATUS=

while [[ $# -gt 0 ]]
do
	key="$1"
	#echo key=$key

	case $key in
	    -c=*|--config=*)
	    FILE_NAME="${key#*=}"
	    shift # past argument=value
	    if [ -f "${FILE_NAME}" ]; then 
		. ${FILE_NAME}
	    else
		usage
	    fi
	    ;;
	    -c|--config)
	    FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    if [ -f "${FILE_NAME}" ]; then 
		. ${FILE_NAME}
	    else
		usage
	    fi
	    ;;
	    -n=*|--name=*)
	    TEST_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -n|--name)
	    TEST_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -a=*|--author=*)
	    AUTHOR="${key#*=}"
	    shift # past argument=value
	    ;;
	    -a|--author)
	    AUTHOR="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -r=*|--referenceId=*)
	    REF_ID="${key#*=}"
	    shift # past argument=value
	    ;;
	    -r|--referenceId)
	    REF_ID="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -m=*|--message=*)
	    MESSAGE="${QTE}${key#*=}${QTE}"
	    shift # past argument=value
	    ;;
	    -m|--message)
	    MESSAGE="${QTE}${2}${QTE}"
	    shift # past argument
	    shift # past value
	    ;;
	    -s=*|--status=*)
	    STATUS="${key#*=}"
	    shift # past argument=value
	    ;;
	    -s|--status)
	    STATUS="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -h|--help|-help)
	    usage
	    exit 0
	    ;;
	    *)
		# unknown option
		echo Unknown Option: $key
		usage
	    ;;
	esac
done
print_settings ${SCRIPT_TYPE} echo "${SCRIPT_TYPE} ${FILE_NAME}"

#echo validate_server
validate_server

#echo validate_session
validate_session

#echo validate_test
validate_test

#echo update_test_data
update_test_data

