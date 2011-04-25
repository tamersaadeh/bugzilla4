#!/bin/sh
# https://bugs.launchpad.net/ubuntu/+source/bugzilla/+bug/419335
set -e

exit 0

echo "> $0 $*"

cd "$1" && patch -p1 < "$0"

exit 0

--- bugzilla-srcdir/Bugzilla/Util.pm-orig	2009-08-26 10:03:35.000000000 -0700
+++ bugzilla-srcdir/Bugzilla/Util.pm	2009-08-26 10:04:00.000000000 -0700
@@ -304,7 +304,7 @@
sub use_attachbase {
    my $attachbase = Bugzilla->params->{'attachment_base'};
-    return ($attachbase ne ''
+    return ($attachbase &&
            && $attachbase ne Bugzilla->params->{'urlbase'}
            && $attachbase ne Bugzilla->params->{'sslbase'}) ? 1 : 0;
}

