#! /bin/sh
# Where to find Python on Debian systems.

set -e

echo "> $0 $*"

for f in `find $1 -name "*.pl" -type f`; do
	if ! head -n 1 $f | grep -q "^#.*!.*perl" $f; then
		cp -p $f $f.new
		echo "#! /usr/bin/perl" > $f.new
		cat $f >> $f.new
		diff -u $f $f.new || true
		mv -f $f.new $f
	fi
done
for f in `find $1 -name "*.py" -type f`; do
	if ! head -n 1 $f | grep -q "^#.*!.*python" $f; then
		cp -p $f $f.new
		echo "#! /usr/bin/python" > $f.new
		cat $f >> $f.new
		diff -u $f $f.new || true
		mv -f $f.new $f
	fi
done
