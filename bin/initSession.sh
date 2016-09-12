#!/bin/bash
#################################################################	
# Description:
#	Initialize the session if there are no active session, otherwise 
# 	close the active session and start a new one
# For usage details run initSession.sh -h
#################################################################	
export SCRIPT_TYPE=session
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
	    NEW_SESSION_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -n|--name)
	    NEW_SESSION_NAME="$2"
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

if [ -f "${FILE_NAME}.session" ];then 
	rm "${FILE_NAME}.session"
fi

validate_server

close_all_opened_sessions

create_new_session

