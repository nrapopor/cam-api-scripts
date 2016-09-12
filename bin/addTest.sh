#!/bin/bash
#################################################################	
# Description:
#	Initialize the new test
# For usage details run addTest.sh -h
#################################################################	
export SCRIPT_TYPE=create
#defaults
. ${0%/*}/cam_setenv.sh
#functions
. ${0%/*}/cam_functions.sh

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

validate_server

validate_session

create_new_test
export TEST_ID=${RET_VAL}

print_settings ${SCRIPT_TYPE} echo TEST_ID=${TEST_ID}


