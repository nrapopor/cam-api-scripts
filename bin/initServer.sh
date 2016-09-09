#!/bin/bash
#################################################################	
# Description:
#	Initialize the server connection with the provided name 
#	or return a reference to the existing connection
# For usage details run initServer.sh -h
#################################################################	
export SCRIPT_TYPE=server
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
	    fi
	    ;;
	    -c|--config)
	    FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    if [ -f "${FILE_NAME}" ]; then 
		. ${FILE_NAME}
	    fi
	    ;;
	    -n=*|--name=*)
	    SERVER_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -n|--name)
	    SERVER_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -u=*|--url=*)
	    SERVER_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -u|--url)
	    SERVER_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -a=*|--agent=*|--agent-url=*)
	    CAM_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -a|--agent|--agent-url)
	    CAM_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -d|--defaults|-defaults)
		echo SERVER_URL=${SERVER_URL}
		echo SERVER_NAME=${SERVER_NAME}
		echo CAM_URL=${CAM_URL}
		exit 0
	    ;;
	    -h|--help|-help)
	    usage
	    ;;
	    *)
		# unknown option
		echo Uknown Option: $key
		usage
	    ;;
	esac
done
print_settings ${SCRIPT_TYPE} echo "${SCRIPT_TYPE} ${FILE_NAME}"

resolve_server
print_settings ${SCRIPT_TYPE} echo SERVER_ID=${SERVER_ID}




