#if [ ! -z "${VERBOSE_SET}" ]; then
#	echo processing parse functions not first time = ${PARSE_FUNCTIONS}
#fi
#if [ -z "${PARSE_FUNCTIONS}" ]; then 
#	export PARSE_FUNCTIONS=true
	. ${0%/*}/util_functions.sh
	. ${0%/*}/parse_usage_functions.sh


	# ########################################################################################
	#	Description
	#		Command line wrapper functions for the RSpec test result parser (for DTP Upload)
	# 	
	#		to increase debug message verbosity set VERBOSE
	# 		to preserve intermediate files set DEBUG_CAM careful that will leave a lot
	#		some locally and some in /tmp 
	# 
	#
	# Prerequisites: JQ, xsltproc, nodejs-legacy, npm 
	#  jq
	#	Ubuntu	 : sudo apt-get install jq
	#	RHEL	 : sudo dnf install jq
	#
	#	Download : wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
	#		   cp jq-linux64 ~/bin
	#		   chmod +x ~/bin/jq-linux64
	#		   ln -s ~/bin/jq-linux64 ~/bin/jq 
	#
	#  xsltproc
	#	Ubuntu   : sudo apt install xsltproc
	#	RHEL	 : sudo yum install xsltproc
	#	Download : Instructions at http://www.sagehill.net/docbookxsl/InstallingAProcessor.html
	#
	#  npm & nodejs
	#	Ubuntu	 : sudo apt-get install npm nodejs-legacy
	#	RHEL	 : sudo yum install epel-release
	#		 : sudo yum install nodejs npm --enablerepo=epel
	#      	Download : Instructions at https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-a-centos-7-server
	#
	# ###################################################################################################################

	# Global		    
	

	#TODO: Parameterize the step size 		
	function calculate_cnt() {
		#requires a variable called CNT to be initialized to Zero prior to the first call
		export CNT=$(expr ${CNT} + 1)
		print_settings ${SCRIPT_TYPE} echo  "Test Number: $CNT" 
		local sofar=$(expr ${CNT} % 100)
		if [ ${CNT} -gt 99 ] && [ $sofar -eq 0 ]; then
			echo "$CNT tests processed so far" 
		fi
	}
	#  API Functions	   
	function parse_api_source() {
		#xsltproc -o report-o.xml rspec_api.xsl ../automation_report_samples/api/report.xml
		xsltproc -o "${TRANSFORMED_XML}" "${0%/*}/rspec_api.xsl" "${API_FILE_NAME}"
		print_settings ${SCRIPT_TYPE} echo "processed xml"

		xml2json < "${TRANSFORMED_XML}" > "${TRANSFORMED_JSON}"
		print_settings ${SCRIPT_TYPE} echo "processed json"

		#export TOTAL_TEST_CNT=$(cat "${TRANSFORMED_JSON}" | jq -c '.tests.test[] | . ' | wc -l )
		cat "${TRANSFORMED_JSON}" | jq -c '.tests.test[] | . ' > ${TEMP_JSON_FILE}
		export TOTAL_TEST_CNT=$(cat ${TEMP_JSON_FILE} | wc -l )
		#export TEST_LIST=$(cat "${TRANSFORMED_JSON}" | jq -c '.tests.test[] | . ' )

		echo processing  ${TOTAL_TEST_CNT} tests
	}

	function clean_up_source() {
		if [ -z "${DEBUG_PARSE}" ]; then
			rm "${TRANSFORMED_XML}"
			rm "${TRANSFORMED_JSON}"
			rm "${TEMP_JSON_FILE}"
		fi
	}
	#  Regression Functions  
	#  Smoke Functions	     
#fi
