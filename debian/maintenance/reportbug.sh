#!/bin/sh
# Copyright (C) 2009  Raphael Bossek <bossekr@debian.org>

set -e

f="/var/log/bugzilla4-install.log"
echo "$f:" >&3
test -e "$f" && \
	cat "$f" >&3
echo "$f: end." >&3
