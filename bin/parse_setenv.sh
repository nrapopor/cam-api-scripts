if [ ! -z "${VERBOSE_SET}" ]; then
	echo processing parse env not first time = ${PARSE_ENV}
fi
if [ -z "${PARSE_ENV}" ]; then
	export PARSE_ENV=true
	. ${0%/*}/cam_setenv.sh
	export API_FILE_NAME=
	export REPORT=
	export CNT=0

fi

