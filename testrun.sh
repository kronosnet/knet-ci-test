#!/bin/sh
echo "Test message 1 from cmdlib"

# TEST - fail only on Debian
if [ -f /etc/debian_version ]
then
    exit 1
fi

exit 0
