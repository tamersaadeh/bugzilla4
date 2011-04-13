#! /bin/sh
# Where to find the duplicats.cgi script.

set -e

echo "> $0 $*"

for f in `find $1 -type f`; do
	if grep -q '\-T duplicates\.cgi' $f; then
		cp -p $f $f.new
		sed -e "s,-T duplicates\.cgi ,-T /usr/share/bugzilla4/web/duplicates.cgi ,g" $f > $f.new
		diff -u $f $f.new || true
		mv -f $f.new $f
	fi
done
