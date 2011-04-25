#!/bin/sh
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594583
# The update_localconfig() function does not allow to change the values
# within Bugzilla program. We have to introduce a new parameter to allow
# runtime localconfig settings.
# If the new paramter is set, new variables do not stop the application.
# This parameter is used by the `bugzparam` scripts to set localconfig
# variables within debconf.

set -e

echo "> $0 $*"

cd "$1" && patch -p1 < "$0"

exit 0

--- a/Bugzilla/Install/Localconfig.pm	2010-10-27 14:23:52.000000000 +0200
+++ b/Bugzilla/Install/Localconfig.pm	2010-10-27 14:26:17.000000000 +0200
@@ -323,7 +323,7 @@
 
     my $output      = $params->{output} || 0;
     my $answer      = Bugzilla->installation_answers;
-    my $localconfig = read_localconfig('include deprecated');
+    my $localconfig = $params->{debian_localconfig} || read_localconfig('include deprecated');
 
     my @new_vars;
     foreach my $var (LOCALCONFIG_VARS) {
@@ -393,7 +393,7 @@
                                      ["*$var->{name}"]);
    }
 
-    if (@new_vars) {
+    if (!$params->{debian_localconfig} && @new_vars) {
         my $newstuff = join(', ', @new_vars);
         print <<EOT;
 
