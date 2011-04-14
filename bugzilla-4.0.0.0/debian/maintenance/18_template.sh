#! /bin/sh

set -e

echo "> $0 $*"

cp -p $1/Bugzilla/Template.pm $1/Bugzilla/Template.pm.new
sed -e "s,VARIABLES => {,VARIABLES => {'Locations' => sub { return Bugzilla->bz_locations()->{\$_[0]}; }\,,g" \
    -e "s,\(delete Bugzilla->request_cache->{template};\),\1 Bugzilla->request_cache->{language} = 'en'; delete Bugzilla->request_cache->{template_include_path_};,g" \
    -e "s,!ON_WINDOWS,0,g" \
    $1/Bugzilla/Template.pm > $1/Bugzilla/Template.pm.new
diff -u $1/Bugzilla/Template.pm $1/Bugzilla/Template.pm.new || true
mv -f $1/Bugzilla/Template.pm.new $1/Bugzilla/Template.pm
