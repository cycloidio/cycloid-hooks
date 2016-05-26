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

HOOKS=$(ls -1 ${TEMPLATE_HOOK_DIR})
PATHS=$(${FIND_BIN} ${GIT_DIR} -maxdepth 2 -iname '.git' -type d)

for PATH in $(echo ${PATHS})
do
	[ ${VERBOSE} ] && echo "Updating $(${BASENAME_BIN} $(${DIRNAME_BIN} ${PATH}))..."
	for HOOK in $(echo "${HOOKS}")
	do
		if [ -f "${PATH}/hooks/${HOOK}" ]; then
			[ ${VERBOSE} ] && echo -e "\tFound ${HOOK}, deleting it"
			${RM_BIN} "${PATH}/hooks/${HOOK}"
		fi
	done
	[ ${VERBOSE} ] && echo -e "\tUsing latest template $(${DIRNAME_BIN} ${PATH})"
	${GIT_BIN} init $(${DIRNAME_BIN} ${PATH}) > /dev/null
	[ ${VERBOSE} ] && echo "Done!"
done

