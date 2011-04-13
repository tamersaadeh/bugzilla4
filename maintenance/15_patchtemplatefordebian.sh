#! /bin/sh
# Static files are not stored within the cgi-bin directory. We have to redirect
# the request to our static directories.

set -e

echo "$0 $*"

BUGZILLA_TEMPLATEDIR="$1/template"
. ./debian/pre-checksetup.d/50patchtemplatefordebian
