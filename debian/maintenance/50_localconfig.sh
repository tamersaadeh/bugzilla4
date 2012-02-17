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

--- a/Bugzilla/Install/Localconfig.pm	2012-02-17 19:03:56 +0100
+++ b/Bugzilla/Install/Localconfig.pm	2012-02-17 19:05:56 +0100
@@ -208,7 +208,7 @@ sub update_localconfig {
 
     my $output      = $params->{output} || 0;
     my $answer      = Bugzilla->installation_answers;
-    my $localconfig = read_localconfig('include deprecated');
+    my $localconfig = $params->{debian_localconfig} || read_localconfig('include deprecated');
 
     my @new_vars;
     foreach my $var (LOCALCONFIG_VARS) {
@@ -273,7 +273,7 @@ sub update_localconfig {
                                      ["*$name"]), "\n";
    }
 
-    if (@new_vars) {
+    if (!$params->{debian_localconfig} && @new_vars) {
         my $newstuff = join(', ', @new_vars);
         print "\n";
         print colored(install_string('lc_new_vars', { localconfig => $filename,
