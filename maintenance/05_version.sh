#! /bin/sh
# Update Bugzilla version to Debian version.

set -e

echo "> $0 $*"

f=`grep -rl 'use constant BUGZILLA_VERSION => ".*";' $1`

v=`dpkg-parsechangelog|grep "^Version: "|cut -d ' ' -f 2`

cp -p $f $f.new
sed -e "s,use constant BUGZILLA_VERSION => \".*\";,use constant BUGZILLA_VERSION => \"$v\";,g" $f > $f.new
diff -u $f $f.new || true
mv -f $f.new $f
