#!/bin/bash
#################################################################	
# Description:
#	process the test detaisl from the PitneyBowes RSpec api 
#	XML into DTP 
# For usage details run parse_api.sh -h
#################################################################	
export SCRIPT_TYPE=parse_api
#defaults
. ${0%/*}/parse_setenv.sh
#functions: for prerequsites see the comments in the ${0%/*}/parse_functions.sh 
. ${0%/*}/parse_functions.sh


while [[ $# -gt 0 ]]
do
	key="$1"
	#echo key=$key

	case $key in
	    -f=*|--inputFile=*)
	    API_FILE_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -f|--inputFile)
	    API_FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -c=*|--config=*)
	    export FILE_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -c|--config)
	    export FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -N=*|--serverName=*)
	    export SERVER_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -N|--serverName)
	    export SERVER_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -u=*|--url=*)
	    export SERVER_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -u|--url)
	    export SERVER_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -a=*|--agent=*|--agent-url=*)
	    export CAM_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -a|--agent|--agent-url)
	    export CAM_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -n=*|--name=*)
	    export REPORT_FILE_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -n|--name)
	    export REPORT_FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -r=*|--reportFolder=*)
	    export REPORT_FOLDER_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -r|--reportFolder)
	    export REPORT_FOLDER_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -P=*|--project=*)
	    export PROJECT="${key#*=}"
	    shift # past argument=value
	    ;;
	    -P|--project)
	    export PROJECT="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -b=*|--buildId=*)
	    export BUILD_ID="${key#*=}"
	    shift # past argument=value
	    ;;
	    -b|--buildId)
	    export BUILD_ID="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -s=*|--sessionTag=*)
	    export SESSION_TAG="${key#*=}"
	    shift # past argument=value
	    ;;
	    -s|--sessionTag)
	    export SESSION_TAG="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -I=*|--coverageImages=*)
	    export COVERAGE_IMAGE="${key#*=}"
	    shift # past argument=value
	    ;;
	    -I|--coverageImages)
	    export COVERAGE_IMAGE="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -S=*|--staticXML=*)
	    export STATIC_COVERAGE_XML="${key#*=}"
	    shift # past argument=value
	    ;;
	    -S|--staticXML)
	    export STATIC_COVERAGE_XML="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -d=*|--dtpURL=*)
	    export DTP_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -d|--dtpURL)
	    export DTP_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -u=*|--dtpUser=*)
	    export DTP_USER="${key#*=}"
	    shift # past argument=value
	    ;;
	    -u|--dtpUser)
	    export DTP_USER="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -p=*|--dtpPassword=*)
	    export DTP_PASSWORD="${key#*=}"
	    shift # past argument=value
	    ;;
	    -p|--dtpPassword)
	    export DTP_PASSWORD="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -U|--upload)
	    export DTP_UPLOAD=true
	    shift # past argument
	    ;;
	    -h|--help|-help)
	    usage
	    ;;
	    *)
		# unknown option
		echo Unknown Option: $key
		usage
	    ;;
	esac
done

required_parameter input "${API_FILE_NAME}"
required_parameter project "${PROJECT}"


# Initialize the Server Connection and a session on CAM 
# the parameters should be set already
${0%/*}/initServer.sh
#print_settings ${SCRIPT_TYPE} 
echo "server initialized"
${0%/*}/initSession.sh
#print_settings ${SCRIPT_TYPE} 
echo "session initialized"
IFS=$'\n'
export TRANSFORMED_XML=/tmp/${TSTAMP_DEFAULT}.api.tests.xml
export TRANSFORMED_JSON=/tmp/${TSTAMP_DEFAULT}.api.tests.json
export TEMP_JSON_FILE=/tmp/hold.${TSTAMP_DEFAULT}.json


parse_api_source

IFS=$'\n'
# Parse the values from the single test's JSON
for i in $( cat ${TEMP_JSON_FILE}); do 
	STAT=$(echo $i | jq ' .status | @sh ')
	NAME_IN=$(echo $i | jq ' .name | @sh')
	# Adding a separator since I'll be appending time to the end of the name to force uniqueness
	NAME="${NAME_IN:1:-1}"~
	MSG=$(echo $i | jq ' .message."$cd" | @sh')
	TYP="$(echo $i | jq -r ' .type | @sh')"
	TIME="$(echo $i | jq -r ' .time ')"

	print_settings ${SCRIPT_TYPE} echo "NAME_IN=${NAME_IN}"	
	print_settings ${SCRIPT_TYPE} echo "NAME=${NAME}"	
	print_settings ${SCRIPT_TYPE} echo "status: $STAT typ: $TYP TIME: $TIME MSG: $MSG Name: $NAME"

	#  Create the test 
	. ${0%/*}/addTest.sh -n "${NAME}"time:${TIME} 
	# Update the test 
	#Author is not passed: the default value of UID will be used
	. ${0%/*}/updateTest.sh -n "${NAME}"time:${TIME} -r "${TYP}" -m "$MSG" -s $STAT
	#print number of tests processed so far
	calculate_cnt
done
#print the total number of tests
#TODO: Add count comparison to the expected total to make sure that all expected tests were processed
echo "$CNT tests processed" 

# the parameters should be set already
# Arguments are not needed since we are exporting the variables ...
#  get the report and dynamic coverage data from CAM 
${0%/*}/getReport.sh 
# Remove any other closed sessions 
${0%/*}/removeClosedSessions.sh
#close this session 
${0%/*}/closeSession.sh 
#you can add the removeClosedSessions again to clean up this session ... It's there as a debug reference 

#clean up intermediate source files (unless DEBUG_PARSE is set) 
clean_up_source 




