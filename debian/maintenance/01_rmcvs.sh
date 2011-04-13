#! /bin/sh

set -e

echo "> $0 $*"

find $1 -type d -name "CVS" -exec rm -rf {} \; >/dev/null 2>&1 || true
find $1 -type d -name ".svn" -exec rm -rf {} \; >/dev/null 2>&1 || true
find $1 -type f -name ".cvsignore" -exec rm {} \; >/dev/null 2>&1 || true
