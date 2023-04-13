#!/bin/sh
#
# Copyright (C) 2023 Red Hat, Inc.  All rights reserved.
#
# Author: Fabio M. Di Nitto <fdinitto@redhat.com>
#
# This software licensed under GPL-2.0+
#

# Run this to generate all the initial makefiles, etc.
autoreconf -i -v && echo Now run ./configure and make
