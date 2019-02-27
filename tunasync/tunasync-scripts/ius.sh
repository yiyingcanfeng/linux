#!/bin/bash

function sync_ius() {
	repo_url="$1"
	repo_dir="$2"

	[ ! -d "$repo_dir" ] && mkdir -p "$repo_dir"
	cd $repo_dir
	lftp "${repo_url}/" -e "mirror --verbose -P 8 --delete --only-missing; bye"
	lftp "${repo_url}/" -e "mirror --verbose -P 8 --only-newer; bye"
}

sync_ius "https://mirrors.aliyun.com/ius/" "${TUNASYNC_WORKING_DIR}" 

