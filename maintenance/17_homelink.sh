#! /bin/sh
# Homepage is index.cgi.

set -e

echo "> $0 $*"

for f in `find $1 -type f`; do
	for s in 'a href="\./"'; do
		if grep -q "$s" $f; then
			cp -p $f $f.new
			sed -e "s,$s;,a href=\"index.cgi\",g" $f > $f.new
			diff -u $f $f.new || true
			mv -f $f.new $f
		fi
	done
done
