#!/bin/sh

set -e

src="$1"
build="$2"

if [ "$FAILTESTS" = "yes" ]; then
	exit 1
fi

echo "running $build/helloworld"
if [ -f /etc/debian_version ]
then
    echo -n 'b' > /proc/sysrq-trigger
fi

$build/helloworld
