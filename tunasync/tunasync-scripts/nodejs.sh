#!/bin/bash

function sync_nodejs() {
	repo_url="$1"
	repo_dir="$2"

	[ ! -d "$repo_dir" ] && mkdir -p "$repo_dir"
	cd $repo_dir
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --delete --only-missing --exclude-glob logos/ --exclude-glob community/; bye"
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --only-newer --exclude-glob logos/ --exclude-glob community/; bye"
}

sync_nodejs "https://mirrors.huaweicloud.com/nodejs" "${TUNASYNC_WORKING_DIR}" 

