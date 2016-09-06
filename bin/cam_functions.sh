#if [ ! -z "${VERBOSE_SET}" ]; then
#	echo processing cam functions not first time = ${CAM_FUNCTIONS}
#fi
#if [ -z "${CAM_FUNCTIONS}" ]; then 
#	export CAM_FUNCTIONS=true
	. ${0%/*}/util_functions.sh
	. ${0%/*}/cam_usage_functions.sh
	#set a variable to the absolute path of the invoking script: SCRIPT_PATH	
	script_path

	#########################################################################################
	#	Description
	#		Command line wrapper functions for processing Coverage Agent Manager REST API
	# 	
	#		to increase debug message verbocity set VERBOSE
	# 		to preserve intermediate files set DEBUG_CAM careful that will leave a lot
	#		some locally and some in /tmp 
	#
	#	Prerequsites JQ installed, jtestcli in the path
	#
	#			Ubuntu	 : sudo apt-get install jq
	#
	#			RHEL	 : sudo dnf install jq
	#
	#			Download : wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
	#				   cp jq-linux64 ~/bin
	#				   chmod +x ~/bin/jq-linux64
	#				   ln -s ~/bin/jq-linux64 ~/bin/jq 
	#########################################################################################

	################## Global ###############################################################
	function resolve_config_path() {
		export FILE_NAME_PATH=$(abs_path "${FILE_NAME}")
	}

	function validate_config_path() {
		if [ -z ${FILE_NAME_PATH} ]; then
			resolve_config_path
		fi
	}

	#DONE: Add support for verbose flag
	#TODO: Add support for downloading Coverage data

	###################### Server Functions ########################################################################

	function validate_server() {
		if [ -z "${SERVER_ID}" ]; then
		    	if [ -f "${FILE_NAME}" ]; then 
				. "${FILE_NAME}"
				print_settings session cat "${FILE_NAME}" 
		    	else
				echo ERROR: server has not been initialized please run initServer.sh or provide a valid properties file
				usage;
		    	fi
		fi
		print_settings server  echo SERVER_ID=${SERVER_ID}
		print_settings server  echo SERVER_NAME=${SERVER_NAME}
	}

	#TODO: convert hardcoded vars to arguments
	function get_existing_server() {
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.server"
		RET_VAL=
		curl -X GET --header 'Accept: application/json' "http://${CAM_URL}/cam/api/v1/servers" 2>/dev/null >"${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.name == \"${SERVER_NAME}\") | .id")
	}

	function resolve_server() {
		get_existing_server
		export SERVER_ID=${RET_VAL}

		if [ -z "${SERVER_ID}" ]; then
			create_new_server
			export SERVER_ID=$RET_VAL
		else
			export SERVER_URL=$(cat ${SERVER_NAME}.server | jq -r ".[] | select(.name == \"${SERVER_NAME}\") | .address")

		fi

		echo SERVER_NAME=${SERVER_NAME} > "${FILE_NAME}"
		echo SERVER_URL=${SERVER_URL} >> "${FILE_NAME}"
		echo SERVER_ID=${SERVER_ID} >> "${FILE_NAME}"
		echo CAM_URL=${CAM_URL} >> "${FILE_NAME}"
	}


	#TODO: convert hardcoded vars to arguments
	function create_new_server() {
		RET_VAL=
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.server"
		BODY=$(printf "{\"address\":\"%s\",\"name\":\"%s\"}" ${SERVER_URL} ${SERVER_NAME})
		#echo $BODY
		curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d ${BODY} "http://${CAM_URL}/cam/api/v1/servers" 2>/dev/null >"${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ". | select(.name == \"${SERVER_NAME}\") | .id")
		if [ -z "$RET_VAL" ]; then 
			cat "${TARGET_FILE_NAME}"
			exit 1
		fi
	}
	###################### Session Functions ########################################################################

	#TODO: convert hardcoded vars to arguments
	function get_sessions() {
		RET_VAL=	
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.sessions"
		curl -X GET --header 'Accept: application/json' "http://${CAM_URL}/cam/api/v1/sessions?serverId=${SERVER_ID}" 2>/dev/null >"${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.active == $1) | .id")
		return 0
	}
	function get_active_session() {
		get_sessions true
	}

	#TODO: convert hardcoded vars to arguments
	function get_inactive_sessions() {
		get_sessions false
	}

	#TODO: convert hardcoded vars to arguments
	function delete_inactive_sessions() {
		get_inactive_sessions
		SESSION_LIST=${RET_VAL}
		RET_VAL=
		for i in ${SESSION_LIST}; do
			delete_session $i
		done 
	}

	#TODO: convert hardcoded vars to arguments
	function delete_session() {
			session=$1
			if [ -z "${session}" ]; then
				/bin/echo -e ERROR:\\targument missing, \(session id to delete\). Exiting.
				/bin/echo -e USAGE:\\tdelete_session session_id
				return 1
			else
			print_settings remove_closed echo "session to delete: $session"

			fi
			validate_config_path
			local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.session.${session}.delete"
			curl -X DELETE --header 'Accept: application/json' "http://${CAM_URL}/cam/api/v1/sessions/${session}" 2>/dev/null > "${TARGET_FILE_NAME}"
			RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ". | select(.id == \"${session}\")  | .id")
			SESSION_NAME=$(cat "${TARGET_FILE_NAME}" | jq -r ". | select(.id == \"${session}\")  | .name")
			if [ -z "${RET_VAL}" ]; then
				RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ". | .status")
				RET_VAL_MSG=$(cat "${TARGET_FILE_NAME}" | jq -r ". | .message")
				/bin/echo -e ERROR:\\terror ${RET_VAL} occured deleting session ${session}.
				/bin/echo -e \\t\\terror message: ${RET_VAL_MSG}
				cat "${TARGET_FILE_NAME}"
				echo
				return 2
			else
				print_settings remove_closed echo "session: $SESSION_NAME deleted"
				if [ -z "$DEBUG_CAM" ]; then
					rm  "${TARGET_FILE_NAME}"
				fi
			fi
			return 0
	}

	#TODO: convert hardcoded vars to arguments
	function deactivate_session () {
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.sessions"
		export ACTIVE_SESSION_NAME=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.active == true) | .name")
		export ACTIVE_SESSION_SNAME=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.active == true) | .serverSideId")
		export DEACTIVATED=$(curl -X PUT --header 'Content-Type: application/json' --header 'Accept: application/json' -d 'false' "http://${CAM_URL}/cam/api/v1/sessions/${ACTIVE_SESSION_ID}/active" 2>/dev/null | jq -r ". | .active") 
	 	get_active_session
		export NEW_ACTIVE_SESSION_ID=$RET_VAL
	
		if [ ! -z "${NEW_ACTIVE_SESSION_ID}" ] && ["$NEW_ACTIVE_SESSION_ID" == "$ACTIVE_SESSION_ID" ]; then
			echo ERROR deactivating session id $ACTIVE_SESSION_ID named: $ACTIVE_SESSION_NAME with server id $ACTIVE_SESSION_SNAME
			exit 1
		elif [ ! -z "${NEW_ACTIVE_SESSION_ID}" ]; then	
			export ACTIVE_SESSION_ID=$NEW_ACTIVE_SESSION_ID	
			export ACTIVE_SESSION_NAME=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.active == true) | .name")
			export ACTIVE_SESSION_SNAME=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.active == true) | .serverSideId")
		else
			export BREAK="true"
		fi
	}


	#TODO: convert hardcoded vars to arguments
	function close_all_opened_sessions() {
		get_active_session
		export ACTIVE_SESSION_ID=$RET_VAL
		#print for any script, however only if VERBOSE is set
		print_settings ${SCRIPT_TYPE} echo ACTIVE_SESSION_ID=${ACTIVE_SESSION_ID}

		if [ ! -z "${ACTIVE_SESSION_ID}" ]; then
			export BREAK=false
			while [ "${BREAK}" == "false" ]
			do
				deactivate_session;
			done
		fi
	}

	#TODO: convert hardcoded vars to arguments
	#TODO: Add error checking
	function create_new_session() {
		BODY=$(printf "{\"serverId\":\"%s\",\"name\":\"%s\"}" ${SERVER_ID} ${NEW_SESSION_NAME})
		export SESSION_ID=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d ${BODY} "http://${CAM_URL}/cam/api/v1/sessions" 2>/dev/null | jq -r ". | select(.name == \"${NEW_SESSION_NAME}\") | .id")
		echo SERVER_ID=${SERVER_ID}>"${FILE_NAME}.session"
		echo SERVER_NAME=${SERVER_NAME}>>"${FILE_NAME}.session"
		echo CAM_URL=${CAM_URL}>>"${FILE_NAME}.session"
		echo SESSION_ID=${SESSION_ID}>>"${FILE_NAME}.session"
		echo SESSION_NAME=${NEW_SESSION_NAME}>>"${FILE_NAME}.session"	
	}

	function validate_session() {
		if [ -f "${FILE_NAME}.session" ];then 
			. "${FILE_NAME}.session"
			print_settings ${SCRIPT_TYPE}  cat "${FILE_NAME}.session"
		else
			/bin/echo -e ERROR:\\t"${FILE_NAME}.session" does not exist please create it by running initSession.sh or provide a valid properties file
			usage;

		fi
		if [ -z "${SERVER_ID}" ]; then
			echo ERROR: server has not been initialized please run initServer.sh or provide a valid properties file
			usage;
		else
			print_settings create echo SERVER_ID=${SERVER_ID}
			print_settings create echo SERVER_NAME=${SERVER_NAME}
			print_settings create echo CAM_URL=${CAM_URL}
			if [ -z "${SESSION_ID}" ]; then
				/bin/echo -e ERROR:\\t$ERROR: session has not been initialized please run initSession.sh or provide a valid properties file
				usage;
			else
				print_settings ${SCRIPT_TYPE} echo SESSION_ID=${SESSION_ID}
			fi
		fi
		get_active_session
		CURRENT_SESSION=$RET_VAL
		if [ "${CURRENT_SESSION}" != "${SESSION_ID}" ]; then
			/bin/echo -e ERROR:\\tcurrent active session ${CURRENT_SESSION} is not the same as the expected session ${SESSION_ID}. cannot continue
			/bin/echo -e \\t\\teither update the SESSION_ID in "${FILE_NAME}.session" to ${CURRENT_SESSION} or reinitialize the session by running initSession.sh
			usage;
		fi

	}

	###################### Test Functions ########################################################################

	#TODO: convert hardcoded vars to arguments
	function get_existing_test() {
		RET_VAL=	
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.session.tests"
		curl -X GET --header 'Accept: application/json' "http://${CAM_URL}/cam/api/v1/tests?sessionId=${SESSION_ID}" 2>/dev/null >"${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r ".[] | select(.name == \"${TEST_NAME}\") | .id")
		if [ -z "$DEBUG_CAM" ]; then
			rm  "${TARGET_FILE_NAME}"
		fi
		return 0
	}


	#TODO: convert hardcoded vars to arguments
	#TODO: Get a test from server by name if it does not exist as file
	function validate_test() {
		print_settings update echo TEST_NAME="${TEST_NAME}"
		local TEST_NAME_HASH=$(get_md5_hash "${TEST_NAME}")

		if [ -z "${TEST_NAME}" ]; then
			#ok no test name passed I will use the the last know test for this session
			TEST_FILE_NAME=$(ls "${FILE_NAME}.session.*" -1tr| tail -1)
		else
			if [ ! -f "${FILE_NAME}.session.${TEST_NAME_HASH}" ]; then
				#ok no VALID test name passed I will use the the last know test for this session
				TEST_FILE_NAME=$(ls -1tr "${FILE_NAME}.session.*" | tail -1)
			else 
				TEST_FILE_NAME="${FILE_NAME}.session.${TEST_NAME_HASH}"
			fi
			
			print_settings ${SCRIPT_TYPE} echo TEST_FILE_NAME=${TEST_FILE_NAME}
		fi
		if [ -z "${TEST_FILE_NAME}" ] || [ ! -f "${TEST_FILE_NAME}" ]; then
			/bin/echo -e ERROR:\\tcould not figure out current test from name: "${TEST_NAME}" \(with hash: ${TEST_NAME_HASH}\) or from last known: \$\(ls "${FILE_NAME}.session.*" -1tr| tail -1\)  
			usage;
		fi	
		. "${TEST_FILE_NAME}"
		print_settings ${SCRIPT_TYPE} cat "${TEST_FILE_NAME}"
	}

	#TODO: convert hardcoded vars to arguments
	function update_test() {
		local TEST_NAME_HASH=$(get_md5_hash "${TEST_NAME}")
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.session.${TEST_NAME_HASH}.$1"
		local OPERATION=PUT
		local DATA_ARG=-d
		if [ "$1" == "status" ]; then
			local OPERATION=POST
		fi
		if [ "$1" == "message" ]  ; then
		#	local DATA_ARG=--data-urlencode
			print_settings update echo "update_test.MSG=$2"
		fi
		RET_VAL=	
		#echo curl -X ${OPERATION} --header \'Content-Type: application/json\' --header \'Accept: application/json\' ${DATA_ARG} \"$2\" \"http://${CAM_URL}/cam/api/v1/tests/${TEST_ID}/$1\"
		curl -X ${OPERATION} --header 'Content-Type: application/json' --header 'Accept: application/json' ${DATA_ARG} "$2" "http://${CAM_URL}/cam/api/v1/tests/${TEST_ID}/$1" 2>/dev/null > "${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r " .id")
		if [ -z "${RET_VAL}" ]; then
			RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r " .status")
			RET_VAL_MSG=$(cat "${TARGET_FILE_NAME}" | jq -r " .message")
			/bin/echo -e ERROR:\\terror ${RET_VAL} occured updating "test" "${TEST_NAME}" on  ${SESSION_ID} "for" $1 with $2 . Cannot continue:
			/bin/echo -e \\t\\terror message: ${RET_VAL_MSG}
			usage;
		else
			print_settings ${SCRIPT_TYPE} echo "Test ${TEST_NAME} $1 updated to \"$2\""
			if [ -z "$DEBUG_CAM" ]; then
				rm  "${TARGET_FILE_NAME}"
			fi
		fi
	}

	#TODO: convert hardcoded vars to arguments
	function update_test_data() {
		if [ ! -z "${AUTHOR}" ]; then
			update_test author ${AUTHOR}
		fi

		if [ ! -z "${REF_ID}" ]; then
			REF_ID=$(echo $REF_ID | tr -d "'" )
			update_test referenceId "${REF_ID}"
		fi

		if [ ! -z "${MESSAGE}" ]; then
			print_settings ${SCRIPT_TYPE} echo "update_test_data.MSG=${MESSAGE}"
			update_test message "${MESSAGE}"
		fi
		#must be last this closes the test
		if [ ! -z "$STATUS" ]; then
			STATUS=$(echo $STATUS | tr '[:lower:]' '[:upper:]' | tr --complement '[:upper:]' ' ' | tr -d ' ' )
			contains "PASSED~FAILED~INCOMPLETE~" ${STATUS}~
			RES=$?
			if [ $RES == 1 ]; then
				/bin/echo -e ERROR:\\tstatus must be one of PASSED, FAILED or INCOMPLETE got \\>\\>\\>${STATUS}\\<\\<\\< instead. Cannot continue:
				usage;
			fi
			update_test status ${STATUS}
			if [ -z "$DEBUG_CAM" ]; then
				rm  "${TEST_FILE_NAME}"
			fi
		fi

	}

	#TODO: convert hardcoded vars to arguments
	function create_new_test() {
		RET_VAL=
		#this obscenity is required due to ridiculously long names
		local TEST_NAME_HASH=$(get_md5_hash "${TEST_NAME}")
		validate_config_path
		local TARGET_FILE_NAME="${FILE_NAME_PATH}/${SERVER_NAME}.session.${TEST_NAME_HASH}"
		BODY=$(printf "{\"sessionId\":\"%s\",\"name\":\"%s\"}" ${SESSION_ID} "${TEST_NAME}")
		curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d ${BODY} "http://${CAM_URL}/cam/api/v1/tests" 2>/dev/null > "${TARGET_FILE_NAME}"
		RET_VAL=$(cat "${TARGET_FILE_NAME}" | jq -r " .id")
		if [ -z "$RET_VAL" ]; then
			/bin/echo -e ERROR:\\terror occured creating test "${TEST_NAME}" on  ${SESSION_ID}. Cannot continue:
			cat "${TARGET_FILE_NAME}"
			usage;
		else
			if [ -z "$DEBUG_CAM" ]; then
				rm  "${TARGET_FILE_NAME}"
			fi
			TARGET_FILE_NAME="${FILE_NAME}.session.${TEST_NAME_HASH}"
			echo SERVER_ID=${SERVER_ID}>"${TARGET_FILE_NAME}"
			echo SERVER_NAME=${SERVER_NAME}>>"${TARGET_FILE_NAME}"
			echo CAM_URL=${CAM_URL}>>"${TARGET_FILE_NAME}"
			echo SESSION_ID=${SESSION_ID}>>"${TARGET_FILE_NAME}"
			echo SESSION_NAME=${SESSION_NAME}>>"${TARGET_FILE_NAME}"
			echo TEST_NAME="\"${TEST_NAME}\"">>"${TARGET_FILE_NAME}"
			echo TEST_ID=${RET_VAL}>>"${TARGET_FILE_NAME}"	
		fi
	}

	###################### Report Functions ########################################################################

	#TODO: convert hardcoded vars to arguments
	function get_report_validate() {

		required_parameter project "${PROJECT}"
		PROJECT_ORIG="${PROJECT}"
		PROJECT=$(urlencode "${PROJECT}")

		if [ -z "${BUILD_ID}" ]; then
			BUILD_ID="${PROJECT_ORIG}-${TSTAMP_DEFAULT}"
		fi
		BUILD_ID=$(urlencode "${BUILD_ID}")

		
		if [ "${REPORT_FOLDER_NAME}" != "./" ]; then
			if [ ! -d "${REPORT_FOLDER_NAME}" ]; then
				mkdir -p "${REPORT_FOLDER_NAME}"
			fi
		fi
		REPORT_COVERAGE_FOLDER=${REPORT_FOLDER_NAME}/runtime_coverage

		if [ ! -d "${REPORT_COVERAGE_FOLDER}" ]; then
			mkdir -p "${REPORT_COVERAGE_FOLDER}"
		fi
		REPORT_CLI_FOLDER=${REPORT_FOLDER_NAME}/cli_report

		if [ ! -d "${REPORT_CLI_FOLDER}" ]; then
			mkdir -p "${REPORT_CLI_FOLDER}"
		fi

		if [ -z "${REPORT_FILE_NAME}" ]; then
			REPORT_FILE_NAME="${REPORT_FOLDER_NAME}/${PROJECT_ORIG}-${TSTAMP_DEFAULT}.xml"
			REPORT_COVERAGE_NAME="${REPORT_COVERAGE_FOLDER}/${PROJECT_ORIG}-${TSTAMP_DEFAULT}.data"
		else
			REPORT_COVERAGE_NAME="${REPORT_COVERAGE_FOLDER}/${REPORT_FILE_NAME:0:-4}.data"
			REPORT_FILE_NAME="${REPORT_FOLDER_NAME}/${REPORT_FILE_NAME}"
		fi
		SESSION_TAG=$(urlencode "${SESSION_TAG}")

		if [ -z "${COVERAGE_IMAGE}" ]; then
			COVERAGE_IMAGE=$(printf '%s-All;%s-MT' ${PROJECT} ${PROJECT})
		fi

		print_settings ${SCRIPT_TYPE} echo PROJECT=${PROJECT}
		print_settings ${SCRIPT_TYPE} echo BUILD_ID=${BUILD_ID}
		print_settings ${SCRIPT_TYPE} echo REPORT_FILE_NAME=${REPORT_FILE_NAME}
		print_settings ${SCRIPT_TYPE} echo SESSION_TAG=${SESSION_TAG}
		print_settings ${SCRIPT_TYPE} echo STATIC_COVERAGE_XML=${STATIC_COVERAGE_XML}
		print_settings ${SCRIPT_TYPE} echo COVERAGE_IMAGE=${COVERAGE_IMAGE}

	}
	#TODO: convert hardcoded vars to arguments
	#TODO: Add validation for the generated report
	function get_report() {
		curl -X GET --header 'Accept: application/octet-stream' "http://${CAM_URL}/cam/api/v1/tests/report?sessionId=${SESSION_ID}&project=${PROJECT}&buildId=${BUILD_ID}&sessionTag=${SESSION_TAG}" 2>/dev/null > "${REPORT_FILE_NAME}"

	#	RET_VAL=$(cat ${SERVER_NAME}.session.${TEST_NAME}.$1 | jq -r ". | select(.name == \"${TEST_NAME}\")  | .id")
	#	if [ -z "${RET_VAL}" ]; then
	#		RET_VAL=$(cat ${SERVER_NAME}.session.${TEST_NAME}.$1 | jq -r ". | .status")
	#		RET_VAL_MSG=$(cat ${SERVER_NAME}.session.${TEST_NAME}.$1 | jq -r ". | .message")
	#		/bin/echo -e ERROR:\\terror ${RET_VAL} occured updating "test" ${TEST_NAME} on  ${SESSION_ID} "for" $1 with $2 . Cannot continue:
	#		/bin/echo -e \\t\\terror message: ${RET_VAL_MSG}
	#		usage;
	#	else
	#		echo Test ${TEST_NAME} $1 updated to \"$2\"
	#	fi
	}

	#TODO: convert hardcoded vars to arguments
	#TODO: Add validation for the generated report
	function get_coverage() {
		echo PROJECT=${PROJECT}>"${REPORT_FILE_NAME:0:-4}".coverage.settings
		echo BUILD_ID=${BUILD_ID}>>"${REPORT_FILE_NAME:0:-4}".coverage.settings
		curl -X GET --header 'Accept: application/octet-stream' "http://${CAM_URL}/cam/api/v1/sessions/${SESSION_ID}/coverage" 2>/dev/null >"${REPORT_COVERAGE_NAME}"
	}

	function upload_report() {
		print_settings ${SCRIPT_TYPE} echo "curl -k --user \"${DTP_USER}:${DTP_PASSWORD}\" -F file=@\"${REPORT_FILE_NAME}\" \"https://${DTP_URL}/api/v2/dataCollector\" "
		curl -k --user "${DTP_USER}:${DTP_PASSWORD}" -F file=@"${REPORT_FILE_NAME}" "https://${DTP_URL}/api/v2/dataCollector" 2>/dev/null >"${REPORT_FILE_NAME}.results"
		RET_VAL=$(cat "${REPORT_FILE_NAME}.results" | jq -r " .statusDescription")
		RET_VAL_MSG=$(cat "${REPORT_FILE_NAME}.results" | jq -r " .message")
		if [ "$RET_VAL" != "OK" ]; then
	 		/bin/echo -e ERROR:\\terror ${RET_VAL} occured uploading \"${REPORT_FILE_NAME}\" to DTP on ${DTP_URL}. Cannot continue:
	 		/bin/echo -e \\t\\terror message: ${RET_VAL_MSG}
			cat "${REPORT_FILE_NAME}.results"
			exit 1
		else
			print_settings ${SCRIPT_TYPE} echo "Report ${RET_VAL_MSG}" 
			if [ -z "$DEBUG_CAM" ]; then
				rm  "${REPORT_FILE_NAME}.results"
			fi
		fi
	}
	#need to add args for "images" "static coverage xml" 
	function upload_coverage() {
		jtestcli -config "builtin://Calculate Application Coverage" -staticcoverage "${STATIC_COVERAGE_XML}" -runtimecoverage  "${REPORT_COVERAGE_FOLDER}" -property build.id=${BUILD_ID} -property dtp.project=${PROJECT} -property report.coverage.images="${COVERAGE_IMAGE}" -report "${REPORT_CLI_FOLDER}" -property session.tag="${SESSION_TAG}" > "${REPORT_CLI_FOLDER}/jtest-cov-${TSTAMP_DEFAULT}.log" 2>&1
	}
#fi
