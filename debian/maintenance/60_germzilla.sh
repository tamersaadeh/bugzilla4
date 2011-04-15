#! /bin/sh
# Fix version check included within Germzilla template.

set -e

echo "$0 $*"

f="$1/template/de/default/global/gzversion.html.tmpl"
test -s "$f"

echo -n >"$f"
