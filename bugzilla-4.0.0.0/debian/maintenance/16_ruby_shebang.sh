#! /bin/sh
# Where to find Python on Debian systems.

set -e

echo "> $0 $*"

for f in `find $1 -type f`; do
	for s in '#.*!.*ruby.*'; do
		if grep -q "^$s" $f; then
			cp -p $f $f.new
			sed -e "s,^$s,#! /usr/bin/ruby,g" $f > $f.new
			diff -u $f $f.new || true
			mv -f $f.new $f
		fi
	done
done
