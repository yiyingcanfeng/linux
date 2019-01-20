#!/bin/bash

function sync_git_for_windows() {
	repo_url="$1"
	repo_dir="$2"

	[ ! -d "$repo_dir" ] && mkdir -p "$repo_dir"
	cd $repo_dir
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --delete --only-missing; bye"
	lftp "${repo_url}/" -e "mirror --verbose -P 5 --only-newer; bye"
}

sync_git_for_windows "https://mirrors.huaweicloud.com/git-for-windows/" "${TUNASYNC_WORKING_DIR}"

