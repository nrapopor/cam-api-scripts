#if [ ! -z "${VERBOSE_SET}" ]; then
#	echo processing util functions not first time = ${UTIL_FUNCTIONS}
#fi
#if [ -z "${UTIL_FUNCTIONS}" ]; then 
#	export UTIL_FUNCTIONS=true

	function script_path() {
		pushd $(dirname $0) > /dev/null
		export SCRIPT_PATH=$(pwd)
		popd > /dev/null
	}

	function abs_path() {
		pushd $(dirname $1) > /dev/null
		local BASEPATH=$(pwd)
		popd > /dev/null
		echo "${BASEPATH}"
	}


	function urlencode() {
	    # urlencode <string>
	    old_lc_collate=$LC_COLLATE
	    LC_COLLATE=C
	    
	    local length="${#1}"
	    for (( i = 0; i < length; i++ )); do
		local c="${1:i:1}"
		case $c in
		    [a-zA-Z0-9.~_-]) printf "$c" ;;
		    *) printf '%%%02X' "'$c" ;;
		esac
	    done
	    
	    LC_COLLATE=$old_lc_collate
	}

	function urldecode() {
	    # urldecode <string>

	    local url_encoded="${1//+/ }"
	    printf '%b' "${url_encoded//%/\\x}"
	}

	function contains() {
	    [[ $1 =~ $2 ]] && return 0 || return 1
	}

	function print_settings() {
		if [ ! -z "$VERBOSE" ] && [ "$SCRIPT_TYPE" == "$1" ]; then
			$2 "$3"
		fi
	}

	function get_md5_hash() {
		echo -n "${1}" | md5sum | cut -d ' ' -f 1
	}

#fi
