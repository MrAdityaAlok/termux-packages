#!/bin/sh

# This script clears about ~22G of space.

# Test:
# echo "Listing 100 largest packages after"
# dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
# exit 0

create_swapfile() {
	sudo fallocate -l 4G /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
}

if [ "${CI-false}" != "true" ]; then
	echo "ERROR: not running on CI, not deleting system files to free space!"
	exit 1
else
	create_swapfile
fi
