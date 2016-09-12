#if [ ! -z "${VERBOSE_SET}" ]; then
#	echo processing parse usage not first time = ${PARSE_USAGE_FUNCTIONS}
#fi
#if [ -z "${PARSE_USAGE_FUNCTIONS}" ]; then 
#	export PARSE_USAGE_FUNCTIONS=true
	. ${0%/*}/cam_setenv.sh
	. ${0%/*}/parse_setenv.sh

	# Usage documentation functions for the Rspec API parser and related support functions

	function common_usage() {
		/bin/echo -e usage:\\t${SCRIPT_NAME}\\t\{-f\[=\]\|--input\[=\]\} \<$1\> \{-P\[=\]\|--project\[=\]\} \<DTP project\> 
		/bin/echo -e \\t\\t\\t\[\{-c\[=\]\|--config\[=\]\} \<server properties\>\] \[\{-N\[=\]\|--serverName\[=\]\} \<server name\>\] 
		/bin/echo -e \\t\\t\\t\[\{-u\[=\]\|--url\[=\]\} \<server url\>\] \[\{-a\[=\]\|--agent\[=\]\|--agent-url\[=\]\} \<CAM url\>\] 
		/bin/echo -e \\t\\t\\t\[\{-n\[=\]\|--name\[=\]\} \<report name\>\] \[\{-r\[=\]\|--reportFolder\[=\]\} \<report folder\>\] 
		/bin/echo -e \\t\\t\\t\\[\{-b\[=\]\|--buildId\[=\]\} \<build id\>\] [\{-s\[=\]\|--sessionTag\[=\]\} \<session tag\>\]  
		/bin/echo -e \\t\\t\\t\[\{-I\[=\]\|--coverageImages\[=\]\} \<coverage images\>\] \[\{-S\[=\]\|--staticXML\[=\]\} \<static xml\>\] 
		/bin/echo -e \\t\\t\\t[\{-d\[=\]\|--dtpURL\[=\]\} \<DTP DC URL\>\] \[\{-u\[=\]\|--dtpUser\[=\]\} \<user name\>\] 
		/bin/echo -e \\t\\t\\t\[\{-p\[=\]\|--dtpPassword\[=\]\} \<DTP password\>\] \[\{-U\[=\]\|--upload\[=\]\}\] \[\{-h\|-help\|--help\}\] 
		/bin/echo -e	
	}

	function common_parameter_description() {
		/bin/echo -e \\tDTP project\\t\\trequired parameter, used to identify the target DTP Project name
		/bin/echo -e
		/bin/echo -e \\tserver properties\\toptional parameter, if the default ${FILE_NAME_DEFAULT} exists 
		/bin/echo -e \\t\\t\\t\\tin the current folder otherwise this parameter is required. 
		/bin/echo -e \\t\\t\\t\\trun: initServer.sh -d \> ${FILE_NAME_DEFAULT} 
		/bin/echo -e \\t\\t\\t\\tto create the default version of the file
		/bin/echo -e
		/bin/echo -e \\tserver name\\t\\toptional parameter, used to lookup the server. 
		/bin/echo -e \\t\\t\\t\\tDefaults to \"${SERVER_NAME_DEFAULT}\" 
		/bin/echo -e \\t\\t\\t\\tWarning:\\tthe the server with the same url, but different name, exists this 
		/bin/echo -e \\t\\t\\t\\t\\t\\tscript will fail, change the SERVER_NAME to the name of the existing server
		/bin/echo -e \\t\\t\\t\\t\\t\\tin your config and try again
		/bin/echo -e
		/bin/echo -e \\tserver url\\t\\toptional parameter, used only when creating the server connection 			
		/bin/echo -e \\t\\t\\t\\t"for" the first time			
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"host:8050\". Defaults to \"${SERVER_URL_DEFAULT}\" 
		/bin/echo -e \\t\\t\\t\\tWarning:\\tif the the server with the same url, but different name, exists 			
		/bin/echo -e \\t\\t\\t\\t\\t\\tthis script will fail
		/bin/echo -e
		/bin/echo -e \\tCAM url\\t\\t\\toptional parameter, used when invoking the CAM \(Coverage Agent Manager\)			
		/bin/echo -e \\t\\t\\t\\tserver "for" all the commands 			
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"host:port\". Defaults to \"${CAM_URL_DEFAULT}\" 
		/bin/echo -e
		/bin/echo -e \\treport name\\t\\toptional parameter, used to determine the name of the report XML. if not  
		/bin/echo -e \\t\\t\\t\\tprovided the a default value will be used based on the format 
		/bin/echo -e \\t\\t\\t\\tFormat:\\t\"\<project name\>.year{4}month{2}day{2}-hour{00-23}minute{00-60}seconds{00-60}-MS{3}.xml\". 
		/bin/echo -e
		/bin/echo -e \\treport folder\\t\\toptional parameter, used to determine the folder "for" the report XML. if not  
		/bin/echo -e \\t\\t\\t\\tprovided the a default value will be used. 
		/bin/echo -e \\t\\t\\t\\tDefailts to \"${REPORT_FOLDER_NAME_DEFAULT}\". 
		/bin/echo -e
		/bin/echo -e \\tDTP project\\t\\trequired parameter, used to identify the target DTP Project name
		/bin/echo -e
		/bin/echo -e \\tbuild id\\t\\toptional parameter, used to determine the build id "for" this report.  
		/bin/echo -e \\t\\t\\t\\tif not provided a default build id will be geenrated based on the format
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
		/bin/echo -e \\t-h\|-help\|--help\\t\\toptional parameter, display this usage message and "exit"
		/bin/echo -e
	}

	function parse_api_usage() {
		common_usage "API report XML"
		/bin/echo 	
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will parse the input RSpec api report xml file and 
		/bin/echo -e \\tgenerate the test results xml file suitable "for" deploying to DTP
		/bin/echo -e \\t\(Parasoft\'s Developmet Testing Platform\)
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\tapi report xml\\t\\trequired parameter, path \(including file name\) to the report xml file to be parsed 
		/bin/echo -e
		common_parameter_description
	 	exit 1
	}
	function parse_regression_usage() {
		common_usage "reports folder"
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will parse the input regression xml files and 
		/bin/echo -e \\tgenerate the test results xml file suitable "for" deploying to DTP
		/bin/echo -e \\t\(Parasoft\'s Developmet Testing Platform\)
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\treports folder\\t\\trequired parameter, path to the regression xml files to be parsed 
		/bin/echo -e	
		common_parameter_description
	 	exit 1
	}
	function parse_smoke_usage() {
		common_usage "reports folder"
		/bin/echo -e Description 	
		/bin/echo -e \\tThis script will parse the input regression xml files and 
		/bin/echo -e \\tgenerate the test results xml file suitable "for" deploying to DTP
		/bin/echo -e \\t\(Parasoft\'s Developmet Testing Platform\)
		/bin/echo -e	
		/bin/echo -e Parameters 	
		/bin/echo -e \\treports folder\\t\\trequired parameter, path to the smoke xml files to be parsed 
		/bin/echo -e	
		common_parameter_description
	 	exit 1
	}


	function usage() {
		export SCRIPT_NAME=$(grep "export SCRIPT_TYPE=" ${0%/*}/*.sh | grep "$SCRIPT_TYPE"| cut -d ':' -f 1)
		if [ "$SCRIPT_TYPE" == "parse_api" ]; then
			parse_api_usage
		elif [ "$SCRIPT_TYPE" == "parse_regression" ]; then
			parse_regression_usage
		else
			parse_smoke_usage
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
