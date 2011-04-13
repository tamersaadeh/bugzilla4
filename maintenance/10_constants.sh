#! /bin/sh

set -e

echo "> $0 $*"

cp -p $1/Bugzilla/Constants.pm $1/Bugzilla/Constants.pm.new
sed -e 's,sub bz_locations ,sub bz_locations_nondebian ,g;/^1;.*/ ,//d' $1/Bugzilla/Constants.pm > $1/Bugzilla/Constants.pm.new
cat `dirname $0`/10_constants.pm >> $1/Bugzilla/Constants.pm.new
diff -u $1/Bugzilla/Constants.pm $1/Bugzilla/Constants.pm.new || true
mv -f $1/Bugzilla/Constants.pm.new $1/Bugzilla/Constants.pm
