#!/bin/bash

[[ "$(id -u)" == "0" ]] && {
        echo "This script can not be run as root." >&2
        exit "0"
}

GREEN='\e[1;92m' RED='\e[1;91m' BLUE='\e[1;94m'
PURPLE='\e[1;95m' YELLOW='\e[1;93m' NC='\033[0m'
CYAN='\e[1;96m' WHITE='\e[1;97m'

URL_USER_JS="https://raw.githubusercontent.com/arkenfox/user.js/master/user.js"
URL_UPDATER_SH="https://raw.githubusercontent.com/arkenfox/user.js/master/updater.sh"
URL_USER_OVERRIDES_JS="https://raw.githubusercontent.com/awnrt/automated-firefox/refs/heads/master/user-overrides.js"
URL_USERCHROME_CSS="https://raw.githubusercontent.com/awnrt/automated-firefox/refs/heads/master/userChrome.css"
URL_USERCONTENT_CSS="https://raw.githubusercontent.com/awnrt/automated-firefox/refs/heads/master/userContent.css"
URL_UBLOCK_BACKUP="https://raw.githubusercontent.com/awnrt/automated-firefox/refs/heads/master/ublock_backup.txt"

FILES_DIR="${HOME}/files"

USERNAME="${HOME//\/home\//}"

set -Eeo pipefail

log_info() {
        sleep "0.3"

        case "${1}" in
                g) COLOR="${GREEN}" MESSAGE="DONE!" ;;
                r) COLOR="${RED}" MESSAGE="WARNING!" ;;
                b) COLOR="${BLUE}" MESSAGE="STARTING." ;;
                c) COLOR="${BLUE}" MESSAGE="RUNNING." ;;
        esac

        COLORED_TASK_INFO="${WHITE}(${CYAN}${TASK_NUMBER}${PURPLE}/${CYAN}${TOTAL_TASKS}${WHITE})"
        MESSAGE_WITHOUT_TASK_NUMBER="${2}"

        DATE="$(date "+%Y-%m-%d ${CYAN}/${PURPLE} %H:%M:%S")"

        FULL_LOG="${CYAN}[${PURPLE}${DATE}${CYAN}] ${YELLOW}>>>${COLOR}${MESSAGE}${YELLOW}<<< ${COLORED_TASK_INFO} - ${COLOR}${MESSAGE_WITHOUT_TASK_NUMBER}${NC}"

        { [[ "${1}" == "c" ]] && echo -e "\n\n${FULL_LOG}"; } || echo -e "${FULL_LOG}"
}

handle_error() {
        error_status="${?}"
        command_line="${BASH_COMMAND}"
        error_line="${BASH_LINENO[0]}"

	log_info r "Error on line ${BLUE}${error_line}${RED}: command ${BLUE}'${command_line}'${RED} exited with status: ${BLUE}${error_status}"
}

trap 'handle_error' ERR
trap 'handle_error' RETURN

declare -A associate_files

associate_f() {
	local key="${1}"
	local url="${2}"
	local base_path="${3}"

	local final_path="${base_path}/${key}"

	associate_files["${key}"]="${url} ${FILES_DIR}/${key} ${final_path}"
}

update_associations() {
	associate_f "user.js" "${URL_USER_JS}" "${LIBREW_PROF_DIR}"
	associate_f "updater.sh" "${URL_UPDATER_SH}" "${LIBREW_PROF_DIR}"
	associate_f "user-overrides.js" "${URL_USER_OVERRIDES_JS}" "${LIBREW_PROF_DIR}"
	associate_f "userChrome.css" "${URL_USERCHROME_CSS}" "${LIBREW_CHROME_DIR}"
	associate_f "userContent.css" "${URL_USERCONTENT_CSS}" "${LIBREW_CHROME_DIR}"
	associate_f "ublock_backup.txt" "${URL_UBLOCK_BACKUP}" "${HOME}"
}

update_associations

move_file() {
	local key="${1}"
	#local custom_destination="${2:-}"
	local download_path final_destination
	IFS=' ' read -r _ download_path final_destination <<< "${associate_files[${key}]}"

	mv -fv "${download_path}" "${final_destination}"
}

update_progress() {
        local total="${1}"
        local current="${2}"
        local pct="$(((current * 100) / total))"
        local filled_blocks="$((pct * 65 / 100))"
        local empty_blocks="$((65 - filled_blocks))"
        local bar=''

        for i in $(seq "1" "${filled_blocks}"); do
                bar="${bar}${GREEN}#${NC}"
        done

        for i in $(seq "1" "${empty_blocks}"); do
                bar="${bar}${RED}-${NC}"
        done

        echo -ne "\r\033[K${bar}${PURPLE} ${pct}%${NC}"
}

download_file() {
	local source="${1}"
	local dest="${2}"

	[ -f "${dest}" ] && {
		log_info b "File ${dest} already exists, skipping download."
		return
	}

	curl -fSLk "${source}" -o "${dest}" > "/dev/null" 2>&1
}

retrieve_files() {
	rm -rfv "${FILES_DIR}" "${HOME}/ublock_backup.txt"
	mkdir -p "${FILES_DIR}"
	local total="$((${#associate_files[@]}))"
	local current="0"

	for key in "${!associate_files[@]}"; do
		current="$((current + 1))"
		update_progress "${total}" "${current}"

		IFS=' ' read -r source dest _ <<< "${associate_files[${key}]}"
		download_file "${source}" "${dest}"
	done

	echo ""
}

create_profile() {
	rm -rfv "${HOME}/.mozilla"
	firefox --headless > "/dev/null" 2>&1 &
	sleep "3"

	killall "firefox"
}

initiate_vars() {
	LIBREW_CONFIG_DIR="${HOME}/.mozilla/firefox"

	LIBREW_PROF_NAME="$(sed -n "/Default=.*\(esr\|release\)$/ { s/Default=//p; q }" \
		"${LIBREW_CONFIG_DIR}/profiles.ini")"

	LIBREW_PROF_DIR="${LIBREW_CONFIG_DIR}/${LIBREW_PROF_NAME}"
	LIBREW_CHROME_DIR="${LIBREW_PROF_DIR}/chrome"

	mkdir -pv "${LIBREW_CHROME_DIR}"

	update_associations
}

place_files() {
	move_file "user.js"
	move_file "user-overrides.js"
	move_file "updater.sh"
	move_file "userChrome.css"
	# move_file "userContent.css"
}

run_arkenfox() {
	chmod +x "${LIBREW_PROF_DIR}/updater.sh"
	#doas chown -R "${USERNAME}":"${USERNAME}" "${HOME}"

	"${LIBREW_PROF_DIR}/updater.sh" -s -u
}

install_extensions() {
	EXT_DIR="${LIBREW_PROF_DIR}/extensions"
	mkdir -pv "${EXT_DIR}"

	ADDON_NAMES=("ublock-origin" "violentmonkey" "darkreader" "vimium-ff")

	for ADDON_NAME in "${ADDON_NAMES[@]}"
	do
		ADDON_URL="$(curl -fSk "https://addons.mozilla.org/en-US/firefox/addon/${ADDON_NAME}/" |
			   grep -o 'https://addons.mozilla.org/firefox/downloads/file/[^"]*')"

		curl -fSLk "${ADDON_URL}" -o "extension.xpi"

		EXT_ID="$(unzip -p "extension.xpi" "manifest.json" | grep "\"id\"")"
		EXT_ID="${EXT_ID%\"*}"
		EXT_ID="${EXT_ID##*\"}"

		mv -fv "extension.xpi" "${EXT_DIR}/${EXT_ID}.xpi"
	done
}

place_ublock_backup() {
	move_file "ublock_backup.txt"
	rm -rfv "${HOME}/files"
}

main() {
        declare -A tasks
        tasks["retrieve_files"]="Retrieve the files.
		        Files retrieved."

        tasks["create_profile"]="Create a profile.
		           A profile created."

        tasks["initiate_vars"]="Initiate new variables.
		             New variabeles initiated."

        tasks["place_files"]="Place the necessary files.
			The necessary files placed."

        tasks["run_arkenfox"]="Run the ArkenFox script.
                                 The Arkenfox script successful."

        tasks["install_extensions"]="Install browser extensions.
                                 Browser extensions installed."


        task_order=("retrieve_files" "create_profile" "initiate_vars" "place_files"
                "run_arkenfox" "install_extensions" "place_ublock_backup")

        TOTAL_TASKS="${#tasks[@]}"
        TASK_NUMBER="1"

        for function in "${task_order[@]}"; do
                description="${tasks[${function}]}"
                description="${description%%$'\n'*}"

		done_message="$(echo "${tasks[${function}]}" | tail -n "1" | sed 's/^[[:space:]]*//g')"

		log_info b "${description}"

		"${function}"
		log_info g "${done_message}"

		[[ "${TASK_NUMBER}" -eq "${TOTAL_TASKS}" ]] && {
			log_info g "All tasks completed."
			break
		}

		((TASK_NUMBER++))
        done
}

main
