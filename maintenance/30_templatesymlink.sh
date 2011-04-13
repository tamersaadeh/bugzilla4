#! /bin/sh
# This message is not detailed enought.

set -e

echo "$0 $*"

f="$1/Bugzilla/Template.pm"
test -s "$f"

cp -p $f $f.new
sed -e 's,"Failed to symlink from,"Failed to symlink in " . abs_path . " from,g' $f > $f.new
diff -u $f $f.new || true
mv -f $f.new $f

