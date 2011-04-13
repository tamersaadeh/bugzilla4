#! /bin/sh
# Where to find the duplicats.cgi script.

set -e

echo "> $0 $*"

for f in `find $1 -type f`; do
	if grep -q "^require 'sanitycheck.cgi';" "$f"; then
		cp -p "$f" "$f.new"
		sed -e "s,^require 'sanitycheck.cgi';.*,require '/usr/share/bugzilla3/web/sanitycheck.cgi';,g" "$f" >"$f.new"
		diff -u "$f" "$f.new" || true
		mv -f "$f.new" "$f"
	fi
done
