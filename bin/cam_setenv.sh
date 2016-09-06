if [ ! -z "${VERBOSE_SET}" ]; then
	echo processing cam env not first time = ${CAM_ENV}
fi
if [ -z "${CAM_ENV}" ]; then
	export CAM_ENV=true
	export FILE_NAME_DEFAULT=./config/CAM.server.config
	export SERVER_URL_DEFAULT=localhost:8050
	export SERVER_NAME_DEFAULT=S1
	export CAM_URL_DEFAULT=localhost:8070
	export DTP_URL_DEFAULT=localhost:8082
	export DTP_USER_DEFAULT=admin
	export DTP_PASSWORD_DEFAULT=admin
	export DTP_UPLOAD_DEFAULT=false
	export REPORT_FOLDER_NAME_DEFAULT=./reports
	export TSTAMP_DEFAULT=$(date +%Y%m%d-%H%M%S-%3N)
	export FORMATTED_DATE=${TSTAMP_DEFAULT:0:-4}
	export SESSION_NAME_DEFAULT=Session-${FORMATTED_DATE}
	export STATIC_COVERAGE_XML_DEFAULT=./static_coverage.xml
	export TEST_NAME_DEFAULT=Test-${TSTAMP_DEFAULT}
	export AUTHOR_DEFAULT=$(id -u -n)
	export DEFAULT_SESSION_TAG="CAM Generated Report"
	export QTE=\'
	export DLR=\$


	##################### Server  ##########################
	export FILE_NAME=${FILE_NAME_DEFAULT}	
	export SERVER_URL=${SERVER_URL_DEFAULT}
	export SERVER_NAME=${SERVER_NAME_DEFAULT}
	export CAM_URL=${CAM_URL_DEFAULT}

	##################### Session #########################
	export NEW_SESSION_NAME=${SESSION_NAME_DEFAULT}

	##################### Tests   #########################
	export TEST_NAME=${TEST_NAME_DEFAULT}

	##################### Reports #########################
	export SESSION_TAG="${DEFAULT_SESSION_TAG}"
	export DTP_URL="${DTP_URL_DEFAULT}"
	export DTP_UPLOAD="${DTP_UPLOAD_DEFAULT}"
	export DTP_USER=${DTP_USER_DEFAULT}
	export DTP_PASSWORD="${DTP_PASSWORD_DEFAULT}"
	export REPORT_FOLDER_NAME="${REPORT_FOLDER_NAME_DEFAULT}"
	export STATIC_COVERAGE_XML="${STATIC_COVERAGE_XML_DEFAULT}"
fi
