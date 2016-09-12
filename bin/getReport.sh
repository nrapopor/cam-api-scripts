#!/bin/bash
#################################################################	
# Description:
#	Get the report for test results and coverage for loading 
#	into DTP
# For usage details run getReport.sh -h
#################################################################
export SCRIPT_TYPE=report
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
	    REPORT_FILE_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -n|--name)
	    REPORT_FILE_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -r=*|--reportFolder=*)
	    REPORT_FOLDER_NAME="${key#*=}"
	    shift # past argument=value
	    ;;
	    -r|--reportFolder)
	    REPORT_FOLDER_NAME="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -P=*|--project=*)
	    PROJECT="${key#*=}"
	    shift # past argument=value
	    ;;
	    -P|--project)
	    PROJECT="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -b=*|--buildId=*)
	    BUILD_ID="${key#*=}"
	    shift # past argument=value
	    ;;
	    -b|--buildId)
	    BUILD_ID="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -s=*|--sessionTag=*)
	    SESSION_TAG="${key#*=}"
	    shift # past argument=value
	    ;;
	    -s|--sessionTag)
	    SESSION_TAG="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -I=*|--coverageImages=*)
	    COVERAGE_IMAGE="${key#*=}"
	    shift # past argument=value
	    ;;
	    -I|--coverageImages)
	    COVERAGE_IMAGE="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -S=*|--staticXML=*)
	    STATIC_COVERAGE_XML="${key#*=}"
	    shift # past argument=value
	    ;;
	    -S|--staticXML)
	    STATIC_COVERAGE_XML="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -d=*|--dtpURL=*)
	    DTP_URL="${key#*=}"
	    shift # past argument=value
	    ;;
	    -d|--dtpURL)
	    DTP_URL="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -u=*|--dtpUser=*)
	    DTP_USER="${key#*=}"
	    shift # past argument=value
	    ;;
	    -u|--dtpUser)
	    DTP_USER="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -p=*|--dtpPassword=*)
	    DTP_PASSWORD="${key#*=}"
	    shift # past argument=value
	    ;;
	    -p|--dtpPassword)
	    DTP_PASSWORD="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -U|--upload|-upload)
	    DTP_UPLOAD=true
	    shift # past argument
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

#echo get_report_validate
get_report_validate

#echo get_report
get_report
get_coverage

if [ "${DTP_UPLOAD}" == "true" ]; then 
	upload_report
	#upload_coverage is currently disabled
	#upload_coverage
fi


