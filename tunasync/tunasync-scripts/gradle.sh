#!/bin/bash

function sync_gradle() {
	repo_url="$1"
	repo_dir="$2"

	[ ! -d "$repo_dir" ] && mkdir -p "$repo_dir"
	cd $repo_dir
	lftp "${repo_url}/" -e "mirror --verbose -P 7 --delete --only-missing; bye"
	lftp "${repo_url}/" -e "mirror --verbose -P 7 --only-newer; bye"
}

sync_gradle "https://services.gradle.org/distributions" "${TUNASYNC_WORKING_DIR}" 

