#! /bin/sh

set -e

echo "> $0 $*"

cp -p $1/Bugzilla/Config.pm $1/Bugzilla/Config.pm.new
sed -e 's,sub read_param_file ,sub read_param_file_nondebian ,g;s,sub write_params ,sub write_params_nondebian ,g;/^1;.*/ ,//d' $1/Bugzilla/Config.pm > $1/Bugzilla/Config.pm.new
cat `dirname $0`/10_config.pm >> $1/Bugzilla/Config.pm.new
diff -u $1/Bugzilla/Config.pm $1/Bugzilla/Config.pm.new || true
mv -f $1/Bugzilla/Config.pm.new $1/Bugzilla/Config.pm
