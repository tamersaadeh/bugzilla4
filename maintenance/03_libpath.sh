#! /bin/sh
# Set the search path for Bugzilla modules.

set -e

echo "> $0 $*"

for f in `find $1 -type f`; do
	for s in "qw(\.)" "['\"]\.\+['\"]" "qw(\. lib)"; do
		if grep -q "^use lib $s" $f; then
			cp -p $f $f.new
			sed -e "s,^use lib $s;,use lib \"/usr/share/bugzilla3\";,g" $f > $f.new
			diff -u $f $f.new || true
			mv -f $f.new $f
		fi
	done
done
