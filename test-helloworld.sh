#!/bin/sh

set -e

src="$1"
build="$2"

if [ -f "/etc/debian_version" ]; then
	exit 1
fi

echo "running $build/helloworld"
$build/helloworld
