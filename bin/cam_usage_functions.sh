#if [ ! -z "${VERBOSE_SET}" ]; then
#	echo processing cam usage not first time = ${CAM_USAGE_FUNCTIONS}
#fi
#if [ -z "${CAM_USAGE_FUNCTIONS}" ]; then 
#	export CAM_USAGE_FUNCTIONS=true
	. ${0%/*}/cam_setenv.sh


	# Usage documentation functions for the CAM wrapper and related support functions

	function server_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t\[\{-c\[=\]\|--config\[=\]\} \<server properties\>\] \[\{-n\[=\]\|--name\[=\]\} \<server name\>\] 
		/bin/echo -e \\t\\t\\t\[\{-u\[=\]\|--url\[=\]\} \<server url\>\] \[\{-a\[=\]\|--agent\[=\]\|--agent-url\[=\]\} \<CAM url\>\] 
		/bin/echo -e \\t\\t\\t\[\{-d\|-defaults\|--defaults\]  \[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will create a new connection "in" the CAM or return an existing one "for"
		/bin/echo -e \\tthe same server name. if there is a server connection with the same url but 
		/bin/echo -e \\ta different name this script will fail
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists 
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT} 
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file
		/bin/echo -e
		/bin/echo -e \\tserver name\\t\\toptional parameter, used to lookup the server. 
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${SERVER_NAME_DEFAULT}\" 
		/bin/echo -e \\t\\t\\t\\tWarning:\\tthe the server with the same url, but different name, exists this 
		/bin/echo -e \\t\\t\\t\\t\\tscript will fail, change the SERVER_NAME to the name of the existing server
		/bin/echo -e \\t\\t\\t\\t\\tin your config and try again
		/bin/echo -e
		/bin/echo -e \\tserver url\\t\\toptional parameter, used only when creating the server connection 			
		/bin/echo -e \\t\\t\\t\\t"for" the first time			
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"host:8050\". Defaults to \"${SERVER_URL_DEFAULT}\" 
		/bin/echo -e \\t\\t\\t\\tWarning:\\tif the the server with the same url, but different name, exists 			
		/bin/echo -e \\t\\t\\t\\t\\tthis script will fail
		/bin/echo -e
		/bin/echo -e \\tCAM url\\t\\t\\toptional parameter, used when invoking the CAM \(Coverage Agent Manager\)			
		/bin/echo -e \\t\\t\\t\\tserver "for" all the commands 			
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"host:port\". Defaults to \"${CAM_URL_DEFAULT}\" 
		/bin/echo -e
		/bin/echo -e \\t-d\|-defaults\|--defaults\\toptional parameter, echo default setting "for" the server properties and exit
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and "exit"
		/bin/echo -e
	 	exit 1
	}

	function session_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t[\{-c\[=\]\|--config\[=\]\} \<server properties\>] [\{-n\[=\]\|--name\[=\]\} \<session name\>]
		/bin/echo -e \\t\\t\\t[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will stop any existing active "test" sessions and create a new one 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists 
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT} 
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file
		/bin/echo -e
		/bin/echo -e \\tsession name\\t\\toptional parameter, used to name the new session. 
		/bin/echo -e \\t\\t\\t\\tDefaults to \"Session-year{4}month{2}day{2}-hour{00-23}minute{00-60}seconds{00-60}\" 
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and exit
		/bin/echo -e
	 	exit 1
	}

	function close_session_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t[\{-c\[=\]\|--config\[=\]\} \<server properties\>] 
		/bin/echo -e \\t\\t\\t[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will deactivate any existing active session 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists 
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT} 
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and exit
		/bin/echo -e
	 	exit 1
	}

	function remove_closed_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t[\{-c\[=\]\|--config\[=\]\} \<server properties\>] 
		/bin/echo -e \\t\\t\\t[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will remove all existing inactive sessions 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists 
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT}   
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and exit
		/bin/echo -e
	 	exit 1
	}

	function test_create_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t[\{-c\[=\]\|--config\[=\]\} \<server properties\>] [\{-n\[=\]\|--name\[=\]\} \<test name\>] 
		/bin/echo -e \\t\\t\\t[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will create a new "test" 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists			
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 			
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT} 
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file you will then neen to run initSession			
		/bin/echo -e \\t\\t\\t\\tto start a new session on the server
		/bin/echo -e
		/bin/echo -e \\ttest name\\t\\toptional parameter, used to name the new test. 
		/bin/echo -e \\t\\t\\t\\tDefaults to \"Test-year{4}month{2}day{2}-hour{00-23}minute{00-60}seconds{00-60}-millis{3}\" 
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and "exit"
		/bin/echo -e
	 	exit 1
	}

	function test_update_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t[\{-c\[=\]\|--config\[=\]\} \<server properties\>] [\{-n\[=\]\|--name\[=\]\} \<test name\>] 
		/bin/echo -e \\t\\t\\t\[\{-a\[=\]\|--author\[=\]\} \<test author\>] [\{-r\[=\]\|--referenceId\[=\]\} \<test ref\>] 
		/bin/echo -e \\t\\t\\t[\{-m\[=\]\|--message\[=\]\} \<test results\>] [\{-s\[=\]\|--status\[=\]\} \<test status\>] 
		/bin/echo -e \\t\\t\\t[\{-h\|-help\|--help\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will update an existing test "test" 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists in the 
		/bin/echo -e \\t\\t\\t\\tcurrent folder, otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT}
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file you will then neen to run initSession to 
		/bin/echo -e \\t\\t\\t\\tstart a new session on the server
		/bin/echo -e
		/bin/echo -e \\ttest name\\t\\toptional parameter, used to determine current test. if not provided the last 
		/bin/echo -e \\t\\t\\t\\tcreated test will be used 
		/bin/echo -e
		/bin/echo -e \\ttest author\\t\\toptional parameter, used to determine current test\'s author. if not provided 
		/bin/echo -e \\t\\t\\t\\twill set to current UID \(${AUTHOR_DEFAULT}\). 
		/bin/echo -e \\t\\t\\t\\tcan be changed in DTP 
		/bin/echo -e
		/bin/echo -e \\ttest ref\\t\\toptional parameter, used to determine current test\'s association to external 
		/bin/echo -e \\t\\t\\t\\tsystem to help with requirement/user story tracking. if not provided will not be set.
		/bin/echo -e \\t\\t\\t\\tCan be changed in DTP 
		/bin/echo -e \\ttest results\\t\\toptional parameter, Results of the tests including any stack traces
		/bin/echo -e
		/bin/echo -e \\ttest status\\t\\toptional parameter, test outcome one of: PASSED, FAILED or INCOMPLETE
		/bin/echo -e
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and "exit"
		/bin/echo -e
	 	exit 1
	}
	function get_report_usage() {
		/bin/echo -e  ################################################ USAGE ########################################
		/bin/echo -e  usage:\\t${SCRIPT_NAME}\\t\[\{-c\[=\]\|--config\[=\]\} \<server properties\>\]\ \[\{-P\[=\]\|--project\[=\]\} \<DTP project\>\] 
		/bin/echo -e \\t\\t\\t\[\{-n\[=\]\|--name\[=\]\} \<report name\>\] \[\{-r\[=\]\|--reportFolder\[=\]\} \<report folder\>\] 
		/bin/echo -e \\t\\t\\t\\[\{-b\[=\]\|--buildId\[=\]\} \<build id\>\] [\{-s\[=\]\|--sessionTag\[=\]\} \<session tag\>\] 
		/bin/echo -e \\t\\t\\t\[\{-I\[=\]\|--coverageImages\[=\]\} \<coverage images\>\] \[\{-S\[=\]\|--staticXML\[=\]\} \<static xml\>\] 
		/bin/echo -e \\t\\t\\t[\{-d\[=\]\|--dtpURL\[=\]\} \<DTP DC URL\>\] \[\{-u\[=\]\|--dtpUser\[=\]\} \<user name\>\] 
		/bin/echo -e \\t\\t\\t\[\{-p\[=\]\|--dtpPassword\[=\]\} \<DTP password\>\] \[\{-U\[=\]\|--upload\[=\]\}\] \[\{-h\|-help\|--help\}\] 
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will update an existing test "test" 	
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists in the 
		/bin/echo -e \\t\\t\\t\\tcurrent folder, otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT}
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file you will then neen to run initSession to 
		/bin/echo -e \\t\\t\\t\\tstart a new session on the server
		/bin/echo -e
		/bin/echo -e \\tDTP project\\t\\trequired parameter, used to identify the target DTP Project name
		/bin/echo -e
		/bin/echo -e \\treport name\\t\\toptional parameter, used to determine the name of the report XML. if not  
		/bin/echo -e \\t\\t\\t\\tprovided the a default value will be used based on the format 
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"\<project name\>.YYYYmmdd-HHMMSS-MS{3}.xml\". 
		/bin/echo -e
		/bin/echo -e \\treport folder\\t\\toptional parameter, used to determine the folder "for" the report XML. if not  
		/bin/echo -e \\t\\t\\t\\tprovided the a default value will be used. 
		/bin/echo -e \\t\\t\\t\\tDefailts to \"${REPORT_FOLDER_NAME_DEFAULT}\". 
		/bin/echo -e
		/bin/echo -e \\tbuild id\\t\\toptional parameter, used to determine the build id "for" this report.  
		/bin/echo -e \\t\\t\\t\\tif not provided a default build id will be generated based on the format
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"\<project name\>.YYYYmmdd-HHMMSS-MS{3}\". 
		/bin/echo -e
		/bin/echo -e \\tsession tag\\t\\toptional parameter, if not provided will default to \"${SESSION_TAG_DEFAULT}\"
		/bin/echo -e
		/bin/echo -e \\tcoverage image\\t\\toptional parameter, used by DTP to filter based on various types of coverage 
		/bin/echo -e \\t\\t\\t\\tif not provided a default coverage image will be generated based on the format.
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"\<project name\>-All;<project name\>-MT\". 
		/bin/echo -e
		/bin/echo -e \\tstatic xml\\t\\toptional parameter, the location and file name of the static coverage Map 
		/bin/echo -e \\t\\t\\t\\tif not provided will default to \"${STATIC_COVERAGE_XML}\"
		/bin/echo -e
		/bin/echo -e \\tDTP DC URL\\t\\toptional parameter, used to determine the url "for" the DTP Data Collector.  
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${DTP_URL_DEFAULT}\"
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"host:port\". Usually the port is 8082 
		/bin/echo -e
		/bin/echo -e \\tDTP user\\t\\toptional parameter, used to determine the user name "for" the DTP Data Collector.  
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${DTP_USER_DEFAULT}\"
		/bin/echo -e
		/bin/echo -e \\tDTP password\\t\\toptional parameter, used to determine the user password "for" the DTP Data Collector.  
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${DTP_PASSWORD_DEFAULT}\"
		/bin/echo -e
		/bin/echo -e \\t-U\|\--upload\\t\\toptional parameter, if passed then it will upload the resulting report to DTP
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${DTP_UPLOAD_DEFAULT}\"
		/bin/echo -e
		/bin/echo -e \\t-h\|--help\\t\\toptional parameter, display this usage message and "exit"
		/bin/echo -e
	 	exit 1
	}


	function usage() {
		export SCRIPT_NAME=$(grep "export SCRIPT_TYPE=" ${0%/*}/*.sh | grep "$SCRIPT_TYPE"| cut -d ':' -f 1)
		if [ "$SCRIPT_TYPE" == "server" ]; then
			server_usage
		elif [ "$SCRIPT_TYPE" == "session" ]; then
			session_usage
		elif [ "$SCRIPT_TYPE" == "close_session" ]; then
			close_session_usage
		elif [ "$SCRIPT_TYPE" == "remove_closed" ]; then
			remove_closed_usage
		elif [ "$SCRIPT_TYPE" == "report" ]; then
			get_report_usage
		elif [ "$SCRIPT_TYPE" == "create" ]; then
			test_create_usage
		else
			test_update_usage
		fi
	}


	function required_parameter() {
		#Usage  required_parameter <arg name> <arg value>
		if [ -z "${2}" ]; then
			/bin/echo 
			/bin/echo -e "######################################"
			/bin/echo -e ERROR:\\t\"$1\" is a required parameter
			/bin/echo -e "######################################"
			usage;
		fi
	}
#fi
