#!/bin/bash

function sync_jdk() {
	repo_url="$1"
	repo_dir="$2"

	[ ! -d "$repo_dir" ] && mkdir -p "$repo_dir"
	cd $repo_dir
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --delete --only-missing; bye"
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --only-newer; bye"
}

sync_jdk "https://mirrors.huaweicloud.com/java/jdk/" "${TUNASYNC_WORKING_DIR}"
