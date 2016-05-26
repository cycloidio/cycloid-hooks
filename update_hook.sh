#!/bin/bash

# Modify those variables with your path
CYCLOID_DIR="$HOME/git/cycloid/"
TEMPLATE_HOOK_DIR="$HOME/.git_template/hooks/"

HOOKS=$(ls -1 ${TEMPLATE_HOOK_DIR})
PATHS=$(find ${CYCLOID_DIR} -maxdepth 2 -iname '.git' -type d)

for PATH in $(echo ${PATHS})
do
	for HOOK in $(echo "${HOOKS}")
	do
		/usr/bin/find ${PATH} -name ${HOOK} -type f # -delete
		echo "Removing ${PATH}/hooks/${HOOK}"
	done
	echo "Updating repository with new template"
	echo "cd ${PATH} && git init && cd -"
	echo ""
done

