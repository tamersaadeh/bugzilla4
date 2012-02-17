#!/bin/sh
# https://bugs.launchpad.net/ubuntu/+source/bugzilla/+bug/419335
set -e

exit 0

echo "> $0 $*"

cd "$1" && patch -p1 < "$0"

exit 0

--- a/Bugzilla/Util.pm	2012-02-17 19:03:56 +0100
+++ b/Bugzilla/Util.pm	2012-02-17 19:03:56 +0100
@@ -301,7 +301,7 @@ sub remote_ip {
 
 sub use_attachbase {
     my $attachbase = Bugzilla->params->{'attachment_base'};
-    return ($attachbase ne ''
+    return ($attachbase &&
             && $attachbase ne Bugzilla->params->{'urlbase'}
             && $attachbase ne Bugzilla->params->{'sslbase'}) ? 1 : 0;
 }
