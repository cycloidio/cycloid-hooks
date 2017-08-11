#!/bin/bash
#
# This script updates all hooks located in the TEMPLATE_HOOK_DIR of all repositories located under the GIT_DIR.
# This allows to easily update hooks to use their latest version.
#

usage()
{
cat << EOF
usage: $0 -r GIT_DIR -t TEMPLATE_HOOK_DIR [-v]

This script updates all hooks located in the TEMPLATE_HOOK_DIR of all repositories located under the GIT_DIR.
This allows to easily update hooks to use their latest version.

OPTIONS:
   -r       Directory containing all repositories
   -t       Template directory containing hooks
   -v       Verbose enablement

Example:
   $0 -r $HOME/git/work/ -t $HOME/.git_template/hooks/ -v
EOF
}

GIT_DIR=""
TEMPLATE_HOOK_DIR=""
VERBOSE=0

while getopts "vt:r:h" opt; do
  case $opt in
    r)
      GIT_DIR=$OPTARG
      ;;
    t)
      TEMPLATE_HOOK_DIR=$OPTARG
      ;;
    v)
      VERBOSE=1
      ;;
    ?)
      usage
      exit 0
      ;;
    h)
      usage
      exit 0
      ;;
  esac
done

if [ ! -d "${GIT_DIR}" ]; then
	echo "Error: Git root directory requires an argument."
	usage
	exit 1
fi
if [ ! -d "${TEMPLATE_HOOK_DIR}" ]; then
	echo "Error: Template directory requires an argument."
	usage
	exit 1
fi

FIND_BIN=$(which find)
RM_BIN=$(which rm)
GIT_BIN=$(which git)
DIRNAME_BIN=$(which dirname)
BASENAME_BIN=$(which basename)
MD5SUM_BIN=$(which md5sum)
AWK_BIN=$(which awk)

HOOKS=$(cd ${TEMPLATE_HOOK_DIR}; ${FIND_BIN} ./ -type f | sed 's/\.\///')
PATHS=$(${FIND_BIN} -L ${GIT_DIR} -maxdepth 2 -iname '.git' -type d)

for PATH in $(echo ${PATHS})
do
	[ ${VERBOSE} -eq 1 ] && echo "Updating $(${BASENAME_BIN} $(${DIRNAME_BIN} ${PATH}))..."
	for HOOK in $(echo "${HOOKS}")
	do
		if [ -e "${PATH}/hooks/${HOOK}" ]; then
			OLD_HASH=$(${MD5SUM_BIN} ${PATH}/hooks/${HOOK} | ${AWK_BIN} '{print $1}')
			NEW_HASH=$(${MD5SUM_BIN} ${TEMPLATE_HOOK_DIR}/${HOOK} | ${AWK_BIN} '{print $1}')
			if [ "${OLD_HASH}" != "${NEW_HASH}" ]; then
				[ ${VERBOSE} -eq 1 ] && echo -e "\tFound ${HOOK}, deleting it"
				${RM_BIN} -rf "${PATH}/hooks/${HOOK}"
			else
				[ ${VERBOSE} -eq 1 ] && echo -e "\tFound ${HOOK}, didn't change"
			fi
		fi
	done
	[ ${VERBOSE} -eq 1 ] && echo -e "\t$(${DIRNAME_BIN} ${PATH}) is using the latest template"
	${GIT_BIN} init $(${DIRNAME_BIN} ${PATH}) > /dev/null
	[ ${VERBOSE} -eq 1 ] && echo "Done!"
done

exit 0
