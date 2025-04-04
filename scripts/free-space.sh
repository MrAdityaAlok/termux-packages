#!/bin/sh

# This script clears about ~22G of space.

# Test:
# echo "Listing 100 largest packages after"
# dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
# exit 0

if [ "${CI-false}" != "true" ]; then
	echo "ERROR: not running on CI, not deleting system files to free space!"
	exit 1
else
	# We shouldn't remove docker & it's images when running from `package_updates` workflow.
	if [ "${CLEAN_DOCKER_IMAGES-true}" = "true" ]; then
		echo "==> Cleaning"
		sudo docker image prune --all --force
		sudo docker builder prune -a
		sudo apt purge -yq containerd.io
	fi
fi
