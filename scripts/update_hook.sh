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
   -c       Create files (instead of using "git init")
   -v       Verbose enablement

The -c option allows keeping hooks out of the git global templatedir.

Examples:
   $0 -r $HOME/git/work/ -t $HOME/.git_template/hooks/ -v
   $0 -r $HOME/git/work/ -t $HOME/git/work/cycloid-hooks/client-side/ -v -c
EOF
}

GIT_DIR=""
TEMPLATE_HOOK_DIR=""
VERBOSE=0
CREATE=0

while getopts "cvt:r:h" opt; do
  case $opt in
    r)
      GIT_DIR=$OPTARG
      ;;
    t)
      TEMPLATE_HOOK_DIR=$OPTARG
      ;;
    c)
      CREATE=1
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

CP_BIN=$(which cp)
MKDIR_BIN=$(which mkdir)
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
                if [ $CREATE -eq 1 ]
                then
				    [ ${VERBOSE} -eq 1 ] && echo -e "\tFound ${HOOK}, replacing it"
				    ${CP_BIN} "${TEMPLATE_HOOK_DIR}/${HOOK}" "${PATH}/hooks/${HOOK}"
                else
				    [ ${VERBOSE} -eq 1 ] && echo -e "\tFound ${HOOK}, deleting it"
				    ${RM_BIN} -rf "${PATH}/hooks/${HOOK}"
                fi
			else
				[ ${VERBOSE} -eq 1 ] && echo -e "\tFound ${HOOK}, didn't change"
			fi
        elif [ $CREATE -eq 1 ]
        then
            [ ${VERBOSE} -eq 1 ] && echo -e "\t${HOOK} not found, creating it"
            ${MKDIR_BIN} -p $(${DIRNAME_BIN} ${PATH}/hooks/${HOOK})
	        ${CP_BIN} "${TEMPLATE_HOOK_DIR}/${HOOK}" "${PATH}/hooks/${HOOK}"
		fi
	done
    if [ $CREATE -eq 0 ]
    then
    	[ ${VERBOSE} -eq 1 ] && echo -e "\t$(${DIRNAME_BIN} ${PATH}) is using the latest template"
	    ${GIT_BIN} init $(${DIRNAME_BIN} ${PATH}) > /dev/null
    fi
	[ ${VERBOSE} -eq 1 ] && echo "Done!"
done

exit 0
