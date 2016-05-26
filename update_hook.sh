#!/bin/bash

# Modify those variables with your path
GIT_DIR="$HOME/git/work/"
TEMPLATE_HOOK_DIR="$HOME/.git_template/hooks/"

FIND_BIN=$(which find)
RM_BIN=$(which rm)
GIT_BIN=$(which git)
DIRNAME_BIN=$(which dirname)
BASENAME_BIN=$(which basename)

HOOKS=$(ls -1 ${TEMPLATE_HOOK_DIR})
PATHS=$(${FIND_BIN} ${GIT_DIR} -maxdepth 2 -iname '.git' -type d)

for PATH in $(echo ${PATHS})
do
	for HOOK in $(echo "${HOOKS}")
	do
		if [ -f "${PATH}/hooks/${HOOK}" ]; then
			${RM_BIN} "${PATH}/hooks/${HOOK}"
		fi
	done
	${GIT_BIN} init $(${DIRNAME_BIN} ${PATH}) > /dev/null
done

