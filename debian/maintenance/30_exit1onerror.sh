#! /bin/sh
# Bugzilla's applications do not exit on an error.

set -e

echo "$0 $*"
d="$1"

tmpf=`tempfile`
trap "rm $tmpf" EXIT QUIT

# Apply the patch.
cat "$0"|patch -d "$d" -p1

# The following check is quality assurence.
if grep -rq "[[:space:]]exit;$" "$d"; then
	cat <<__EOF__
---8<---8<---8<---8<---8<---8<---8<---8<---8<---8<---8<---
There should not exist any exit without an return value.
Please tune the patch if you make an update of bugzilla:
__EOF__
	grep -r "[[:space:]]exit;$" "$d"|cat -n
	exit 1
fi
if ! grep -q "exit(9);$" "$d/Bugzilla/Install/Localconfig.pm"; then
	cat <<__EOF__
It's important to exit with error code 9 in the case where
/etc/bugzilla4/localconfig file is updated.
In this case /usr/share/bugzilla4/lib/checksetup.pl restart
checksetup. Please modify debian/maintenance/checksetup_debian.sh
otherwise.
__EOF__
	exit 2
fi

exit 0
diff -Naur bugzilla-srcdir.orig//attachment.cgi bugzilla-srcdir/attachment.cgi
--- bugzilla-srcdir.orig//attachment.cgi	2010-11-12 10:26:24.156917777 +0100
+++ bugzilla-srcdir/attachment.cgi	2010-11-12 10:28:19.701917501 +0100
@@ -130,7 +130,7 @@
   ThrowCodeError("unknown_action", { action => $action });
 }
 
-exit;
+exit(0);
 
 ################################################################################
 # Data Validation / Security Authorization
@@ -161,7 +161,7 @@
         print $cgi->header();
         $template->process("attachment/choose.html.tmpl", $vars) ||
             ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
     
     my $attach_id = $cgi->param($param);
@@ -263,7 +263,7 @@
                 {
                     # Not a valid token.
                     print $cgi->redirect('-location' => correct_urlbase() . $path);
-                    exit;
+                    exit(0);
                 }
                 # Change current user without creating cookies.
                 Bugzilla->set_user(new Bugzilla::User($userid));
@@ -289,13 +289,13 @@
             if (attachmentIsPublic($attachment)) {
                 # No need for a token; redirect to attachment base.
                 print $cgi->redirect(-location => $attachbase . $path);
-                exit;
+                exit(0);
             } else {
                 # Make sure the user can view the attachment.
                 check_can_access($attachment);
                 # Create a token and redirect.
                 my $token = url_quote(issue_session_token($attachment->id));
                 print $cgi->redirect(-location => $attachbase . "$path&t=$token");
-                exit;
+                exit(0);
             }
         }
     } else {
@@ -465,7 +465,7 @@
             print $cgi->header();
             $template->process("attachment/cancel-create-dupe.html.tmpl",  $vars)
                 || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
     }
 
@@ -627,7 +627,7 @@
                 # Warn the user about the mid-air collision and ask them what to do.
                 $template->process("attachment/midair.html.tmpl", $vars)
                   || ThrowTemplateError($template->error());
-                exit;
+                exit(1);
             }
         }
     }
diff -Naur bugzilla-srcdir.orig//buglist.cgi bugzilla-srcdir/buglist.cgi
--- bugzilla-srcdir.orig//buglist.cgi	2010-11-12 10:26:39.540915708 +0100
+++ bugzilla-srcdir/buglist.cgi	2010-11-12 10:28:19.705916808 +0100
@@ -81,6 +81,6 @@
     $vars->{'url'} = $url;
     $template->process("global/message.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }

@@ -493,7 +493,7 @@
         $vars->{'url'} = "query.cgi";
         $template->process("global/message.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 }
 elsif (($cmdtype eq "doit") && defined $cgi->param('remtype')) {
@@ -596,7 +596,7 @@
         print $cgi->header();
         $template->process("global/message.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 }
 
diff -Naur bugzilla-srcdir.orig//Bugzilla/Auth/Login/CGI.pm bugzilla-srcdir/Bugzilla/Auth/Login/CGI.pm
--- bugzilla-srcdir.orig//Bugzilla/Auth/Login/CGI.pm	2010-03-24 00:21:18.000000000 +0100
+++ bugzilla-srcdir/Bugzilla/Auth/Login/CGI.pm	2010-11-12 10:28:19.705916808 +0100
@@ -68,7 +68,7 @@
     $template->process("account/auth/login.html.tmpl",
                        { 'target' => $cgi->url(-relative=>1) }) 
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 1;
diff -Naur bugzilla-srcdir.orig//Bugzilla/Bug.pm bugzilla-srcdir/Bugzilla/Bug.pm
--- bugzilla-srcdir.orig//Bugzilla/Bug.pm	2010-10-28 17:35:01.000000000 +0200
+++ bugzilla-srcdir/Bugzilla/Bug.pm	2010-11-12 10:28:19.709917012 +0100
@@ -1581,7 +1581,7 @@
             print $cgi->header();
             $template->process("bug/process/confirm-duplicate.html.tmpl", $vars)
               || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
     }
 
@@ -2460,7 +2460,7 @@
             my $template = Bugzilla->template;
             $template->process("bug/process/verify-new-product.html.tmpl",
                 \%vars) || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
     }
     else {
diff -Naur bugzilla-srcdir.orig//Bugzilla/CGI.pm bugzilla-srcdir/Bugzilla/CGI.pm
--- bugzilla-srcdir.orig//Bugzilla/CGI.pm	2010-11-03 00:35:08.000000000 +0100
+++ bugzilla-srcdir/Bugzilla/CGI.pm	2010-11-12 10:28:19.709917012 +0100
@@ -457,7 +457,7 @@
 
     # When using XML-RPC with mod_perl, we need the headers sent immediately.
     $self->r->rflush if $ENV{MOD_PERL};
-    exit;
+    exit(0);
 }
 
 # Redirect to the urlbase version of the current URL.
@@ -480,7 +480,7 @@
     my $self = shift;
     my $path = $self->url('-path_info' => 1, '-query' => 1, '-relative' => 1);
     print $self->redirect('-location' => correct_urlbase() . $path);
-    exit;
+    exit(0);
 }
 
 sub url_is_attachment_base {
diff -Naur bugzilla-srcdir.orig//Bugzilla/DB/Mysql.pm bugzilla-srcdir/Bugzilla/DB/Mysql.pm
--- bugzilla-srcdir.orig//Bugzilla/DB/Mysql.pm	2010-02-01 00:39:14.000000000 +0100
+++ bugzilla-srcdir/Bugzilla/DB/Mysql.pm	2010-11-12 10:28:19.709917012 +0100
@@ -726,8 +726,8 @@
          Re-run checksetup.pl in interactive mode (without an 'answers' file)
          to continue.
 EOT
-                exit;
+                exit(1);
             }
             else {
                 print "         Press Enter to continue or Ctrl-C to exit...";

diff -Naur bugzilla-srcdir.orig//Bugzilla/Error.pm bugzilla-srcdir/Bugzilla/Error.pm
--- bugzilla-srcdir.orig//Bugzilla/Error.pm	2010-04-01 03:17:35.000000000 +0200
+++ bugzilla-srcdir/Bugzilla/Error.pm	2010-11-12 10:28:19.713916614 +0100
@@ -154,7 +154,7 @@
             }
         }
     }
-    exit;
+    exit(1);
 }
 
 sub ThrowUserError {
@@ -208,7 +208,7 @@
         </tt>
 END
     }
-    exit;
+    exit(1);
 }
 
 1;
diff -Naur bugzilla-srcdir.orig//Bugzilla/Install/Localconfig.pm bugzilla-srcdir/Bugzilla/Install/Localconfig.pm
--- bugzilla-srcdir.orig//Bugzilla/Install/Localconfig.pm	2010-04-22 20:22:50.000000000 +0200
+++ bugzilla-srcdir/Bugzilla/Install/Localconfig.pm	2010-11-12 10:28:19.713916614 +0100
@@ -405,7 +405,7 @@
 checksetup.pl:  $newstuff
 
 EOT
-        exit;
+        exit(9);
     }
 
     # Reset the cache for Bugzilla->localconfig so that it will be re-read
diff -Naur bugzilla-srcdir.orig//Bugzilla/Search/Quicksearch.pm bugzilla-srcdir/Bugzilla/Search/Quicksearch.pm
--- bugzilla-srcdir.orig//Bugzilla/Search/Quicksearch.pm	2010-09-21 20:02:13.000000000 +0200
+++ bugzilla-srcdir/Bugzilla/Search/Quicksearch.pm	2010-11-12 10:28:19.713916614 +0100
@@ -235,7 +235,7 @@
         # Single bug number; shortcut to show_bug.cgi.
         print $cgi->redirect(
             -uri => correct_urlbase() . "show_bug.cgi?id=$searchstring");
-        exit;
+        exit(0);
     }
     else {
         # List of bug numbers.
@@ -256,7 +256,7 @@
         if ($is_alias) {
             print Bugzilla->cgi->redirect(
                 -uri => correct_urlbase() . "show_bug.cgi?id=$alias");
-            exit;
+            exit(0);
         }
     }
 }
diff -Naur bugzilla-srcdir.orig//Bugzilla/Token.pm bugzilla-srcdir/Bugzilla/Token.pm
--- bugzilla-srcdir.orig//Bugzilla/Token.pm	2009-12-31 13:53:19.000000000 +0100
+++ bugzilla-srcdir/Bugzilla/Token.pm	2010-11-12 10:28:19.717916713 +0100
@@ -219,7 +219,7 @@
         print Bugzilla->cgi->header();
         $template->process('global/confirm-action.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 
     # If we come here, then the token is valid and not too old.
@@ -400,7 +400,7 @@
 
         $template->process('admin/confirm-action.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
     return 1;
 }
diff -Naur bugzilla-srcdir.orig//Bugzilla/User.pm bugzilla-srcdir/Bugzilla/User.pm
--- bugzilla-srcdir.orig//Bugzilla/User.pm	2010-02-18 01:34:42.000000000 +0100
+++ bugzilla-srcdir/Bugzilla/User.pm	2010-11-12 10:28:19.717916713 +0100
@@ -1486,7 +1486,7 @@
 
     $template->process("global/confirm-user-match.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 
 }
 
diff -Naur bugzilla-srcdir.orig//Bugzilla.pm bugzilla-srcdir/Bugzilla.pm
--- bugzilla-srcdir.orig//Bugzilla.pm	2010-11-12 10:27:20.664915051 +0100
+++ bugzilla-srcdir/Bugzilla.pm	2010-11-12 10:28:19.721916586 +0100
@@ -141,7 +141,7 @@ sub init_page {
         if (!i_am_cgi()
             && grep { $_ eq $script } SHUTDOWNHTML_EXIT_SILENTLY)
         {
-            exit;
+            exit(0);
         }
 
         # For security reasons, log out users when Bugzilla is down.
@@ -175,7 +175,7 @@ sub init_page {
         $template->process("global/message.$extension.tmpl", $vars, \$t_output)
             || ThrowTemplateError($template->error);
         print $t_output . "\n";
-        exit;
+        exit(1);
     }
 }
 
diff -Naur bugzilla-srcdir.orig//chart.cgi bugzilla-srcdir/chart.cgi
--- bugzilla-srcdir.orig//chart.cgi	2010-11-12 10:26:25.625929357 +0100
+++ bugzilla-srcdir/chart.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -76,7 +76,7 @@ if (grep(/^cmd-/, $cgi->param())) {
     my $params = $cgi->canonicalise_query("format", "ctype", "action");
     print $cgi->redirect("query.cgi?format=" . $cgi->param('query_format') .
                                                ($params ? "&$params" : ""));
-    exit;
+    exit(0);
 }
 
 my $action = $cgi->param('action');
@@ -99,7 +99,7 @@ $action ||= "assemble";
 if ($action eq "search") {
     my $params = $cgi->canonicalise_query("format", "ctype", "action");
     print $cgi->redirect("buglist.cgi" . ($params ? "?$params" : ""));
-    exit;
+    exit(0);
 }
 
 $user->in_group(Bugzilla->params->{"chartgroup"})
@@ -234,7 +234,7 @@ else {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit(0);
 
 # Find any selected series and return either the first or all of them.
 sub getAndValidateSeriesIDs {
diff -Naur bugzilla-srcdir.orig//colchange.cgi bugzilla-srcdir/colchange.cgi
--- bugzilla-srcdir.orig//colchange.cgi	2010-11-12 10:26:23.916940016 +0100
+++ bugzilla-srcdir/colchange.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -165,12 +165,12 @@ if (defined $cgi->param('rememberedquery')) {
     }
     else {
       print $cgi->redirect($vars->{'redirect_url'});
-      exit;
+      exit(0);
     }
     
     $template->process("global/message.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if (defined $cgi->param('columnlist')) {
diff -Naur bugzilla-srcdir.orig//config.cgi bugzilla-srcdir/config.cgi
--- bugzilla-srcdir.orig//config.cgi	2010-11-12 10:26:39.496917725 +0100
+++ bugzilla-srcdir/config.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -162,5 +162,5 @@ sub display_data {
                             -type => $format->{'ctype'});
         print $output;
     }
-    exit;
+    exit(0);
 }
diff -Naur bugzilla-srcdir.orig//contrib/recode.pl bugzilla-srcdir/contrib/recode.pl
--- bugzilla-srcdir.orig//contrib/recode.pl	2010-11-12 10:26:25.192920218 +0100
+++ bugzilla-srcdir/contrib/recode.pl	2010-11-12 10:28:19.721916586 +0100
@@ -157,7 +157,7 @@
   $^X install-module.pl Encode::Detect
 
 EOT
-        exit;
+        exit(1);
     }
 
     import Encode::Detect::Detector qw(detect);
diff -Naur bugzilla-srcdir.orig//contrib/sendbugmail.pl bugzilla-srcdir/contrib/sendbugmail.pl
--- bugzilla-srcdir.orig//contrib/sendbugmail.pl	2010-11-12 10:26:25.008928823 +0100
+++ bugzilla-srcdir/contrib/sendbugmail.pl	2010-11-12 10:28:19.721916586 +0100
@@ -26,7 +26,7 @@
 
 sub usage {
     print STDERR "Usage: $0 bug_id user_email\n";
-    exit;
+    exit(1);
 }
 
 if (($#ARGV < 1) || ($#ARGV > 2)) {
diff -Naur bugzilla-srcdir.orig//contrib/syncLDAP.pl bugzilla-srcdir/contrib/syncLDAP.pl
--- bugzilla-srcdir.orig//contrib/syncLDAP.pl	2010-11-12 10:26:25.208930927 +0100
+++ bugzilla-srcdir/contrib/syncLDAP.pl	2010-11-12 10:28:19.721916586 +0100
@@ -70,7 +70,7 @@ foreach my $arg (@ARGV)
          print " -c No create, don't create users, which are in LDAP but not in Bugzilla\n";
          print " -q Quiet mode, give less output\n";
          print "\n";
-         exit;
+         exit(1)(1);
    }
 }
 
@@ -94,7 +94,7 @@ foreach my $login_name (keys %bugzilla_users) {
 my $LDAPserver = Bugzilla->params->{"LDAPserver"};
 if ($LDAPserver eq "") {
    print "No LDAP server defined in bugzilla preferences.\n";
-   exit;
+   exit(1);
 }
 
 my $LDAPconn;
@@ -111,7 +111,7 @@ if($LDAPserver =~ /:\/\//) {
 
 if(!$LDAPconn) {
    print "Connecting to LDAP server failed. Check LDAPserver setting.\n";
-   exit;
+   exit(1);
 }
 my $mesg;
 if (Bugzilla->params->{"LDAPbinddn"}) {
@@ -123,7 +123,7 @@ else {
 }
 if($mesg->code) {
    print "Binding to LDAP server failed: " . $mesg->error . "\nCheck LDAPbinddn setting.\n";
-   exit;
+   exit(1);
 }
 
 # We've got our anonymous bind;  let's look up the users.
@@ -135,7 +135,7 @@ $mesg = $LDAPconn->search( base   => Bugzilla->params->{"LDAPBaseDN"},
 
 if(! $mesg->count) {
    print "LDAP lookup failure. Check LDAPBaseDN setting.\n";
-   exit;
+   exit(1);
 }
    
 my %val = %{ $mesg->as_struct };
diff -Naur bugzilla-srcdir.orig//createaccount.cgi bugzilla-srcdir/createaccount.cgi
--- bugzilla-srcdir.orig//createaccount.cgi	2010-11-12 10:26:23.609427775 +0100
+++ bugzilla-srcdir/createaccount.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -77,7 +77,7 @@
 
     $template->process("account/created.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 # Show the standard "would you like to create an account?" form.
diff -Naur bugzilla-srcdir.orig//describecomponents.cgi bugzilla-srcdir/describecomponents.cgi
--- bugzilla-srcdir.orig//describecomponents.cgi	2010-11-12 10:26:23.441434910 +0100
+++ bugzilla-srcdir/describecomponents.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -73,7 +73,7 @@
 
         $template->process("global/choose-product.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 
     # If there is only one product available and the user didn't specify
diff -Naur bugzilla-srcdir.orig//editclassifications.cgi bugzilla-srcdir/editclassifications.cgi
--- bugzilla-srcdir.orig//editclassifications.cgi	2010-11-12 10:26:24.104928811 +0100
+++ bugzilla-srcdir/editclassifications.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -54,7 +54,7 @@
     print $cgi->header();
     $template->process("admin/classifications/$action.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
diff -Naur bugzilla-srcdir.orig//editcomponents.cgi bugzilla-srcdir/editcomponents.cgi
--- bugzilla-srcdir.orig//editcomponents.cgi	2010-11-12 10:26:24.920955767 +0100
+++ bugzilla-srcdir/editcomponents.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -83,7 +83,7 @@
 
     $template->process("admin/components/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -97,7 +97,7 @@
     $vars->{'product'} = $product;
     $template->process("admin/components/list.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -111,7 +111,7 @@
     $vars->{'product'} = $product;
     $template->process("admin/components/create.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -151,7 +151,7 @@
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -168,7 +168,7 @@
 
     $template->process("admin/components/confirm-delete.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -190,7 +190,7 @@
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -212,7 +212,7 @@
 
     $template->process("admin/components/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -252,7 +252,7 @@
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
diff -Naur bugzilla-srcdir.orig//editflagtypes.cgi bugzilla-srcdir/editflagtypes.cgi
--- bugzilla-srcdir.orig//editflagtypes.cgi	2010-11-12 10:26:39.456938968 +0100
+++ bugzilla-srcdir/editflagtypes.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -73,7 +73,7 @@ my @categoryActions;
 if (@categoryActions = grep(/^categoryAction-.+/, $cgi->param())) {
     $categoryActions[0] =~ s/^categoryAction-//;
     processCategoryChange($categoryActions[0], $token);
-    exit;
+    exit(0);
 }
 
 if    ($action eq 'list')           { list();           }
@@ -89,7 +89,7 @@ else {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit(0);
 
 ################################################################################
 # Functions
diff -Naur bugzilla-srcdir.orig//editgroups.cgi bugzilla-srcdir/editgroups.cgi
--- bugzilla-srcdir.orig//editgroups.cgi	2010-11-12 10:26:25.248917828 +0100
+++ bugzilla-srcdir/editgroups.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -157,7 +157,7 @@ unless ($action) {
     print $cgi->header();
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -179,7 +179,7 @@ if ($action eq 'changeform') {
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -194,7 +194,7 @@ if ($action eq 'add') {
     $template->process("admin/groups/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
     
-    exit;
+    exit(1);
 }
 
 
@@ -231,7 +231,7 @@ if ($action eq 'new') {
     print $cgi->header();
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -256,7 +256,7 @@ if ($action eq 'del') {
     $template->process("admin/groups/delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
     
-    exit;
+    exit(1);
 }
 
 #
@@ -282,7 +282,7 @@ if ($action eq 'delete') {
     print $cgi->header();
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -304,7 +304,7 @@ if ($action eq 'postchanges') {
     print $cgi->header();
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if ($action eq 'confirm_remove') {
@@ -314,7 +314,7 @@ if ($action eq 'confirm_remove') {
     $vars->{'token'} = issue_session_token('remove_group_members');
     $template->process('admin/groups/confirm-remove.html.tmpl', $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if ($action eq 'remove_regexp') {
@@ -354,7 +354,7 @@ if ($action eq 'remove_regexp') {
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editkeywords.cgi bugzilla-srcdir/editkeywords.cgi
--- bugzilla-srcdir.orig//editkeywords.cgi	2010-11-12 10:26:24.000917760 +0100
+++ bugzilla-srcdir/editkeywords.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -62,7 +62,7 @@ if ($action eq "") {
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
     
 
@@ -74,7 +74,7 @@ if ($action eq 'add') {
     $template->process("admin/keywords/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -98,7 +98,7 @@ if ($action eq 'new') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 
@@ -118,7 +118,7 @@ if ($action eq 'edit') {
     print $cgi->header();
     $template->process("admin/keywords/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 
@@ -148,7 +148,7 @@ if ($action eq 'update') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if ($action eq 'del') {
@@ -161,7 +161,7 @@ if ($action eq 'del') {
     print $cgi->header();
     $template->process("admin/keywords/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if ($action eq 'delete') {
@@ -181,7 +181,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 ThrowUserError('unknown_action', {action => $action});
diff -Naur bugzilla-srcdir.orig//editmilestones.cgi bugzilla-srcdir/editmilestones.cgi
--- bugzilla-srcdir.orig//editmilestones.cgi	2010-11-12 10:26:24.040930488 +0100
+++ bugzilla-srcdir/editmilestones.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -77,7 +77,7 @@ unless ($product_name) {
 
     $template->process("admin/milestones/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -92,7 +92,7 @@ unless ($action) {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -106,7 +106,7 @@ if ($action eq 'add') {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -125,7 +125,7 @@ if ($action eq 'new') {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -149,7 +149,7 @@ if ($action eq 'del') {
 
     $template->process("admin/milestones/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -170,7 +170,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -190,7 +190,7 @@ if ($action eq 'edit') {
 
     $template->process("admin/milestones/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -218,7 +218,7 @@ if ($action eq 'update') {
     $vars->{'changes'} = $changes;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editproducts.cgi bugzilla-srcdir/editproducts.cgi
--- bugzilla-srcdir.orig//editproducts.cgi	2010-11-12 10:26:24.176934711 +0100
+++ bugzilla-srcdir/editproducts.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -95,7 +95,7 @@ if (Bugzilla->params->{'useclassification'}
 
     $template->process("admin/products/list-classifications.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 
@@ -129,7 +129,7 @@ if (!$action && !$product_name) {
 
     $template->process("admin/products/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 
@@ -158,7 +158,7 @@ if ($action eq 'add') {
     $template->process("admin/products/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 
@@ -199,7 +199,7 @@ if ($action eq 'new') {
 
     $template->process("admin/products/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -221,7 +221,7 @@ if ($action eq 'del') {
     
     $template->process("admin/products/confirm-delete.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -258,7 +258,7 @@ if ($action eq 'delete') {
         $template->process("admin/products/list.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
     }
-    exit;
+    exit(1);
 }
 
 #
@@ -279,7 +279,7 @@ if ($action eq 'edit' || (!$action && $product_name)) {
 
     $template->process("admin/products/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -310,7 +310,7 @@ if ($action eq 'update') {
 
     $template->process("admin/products/updated.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -325,7 +325,7 @@ if ($action eq 'editgroupcontrols') {
 
     $template->process("admin/products/groupcontrol/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -394,7 +394,7 @@ if ($action eq 'updategroupcontrols') {
             $vars->{'mandatory_groups'} = $mandatory_groups;
             $template->process("admin/products/groupcontrol/confirm-edit.html.tmpl", $vars)
                 || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
     }
 
@@ -419,7 +419,7 @@ if ($action eq 'updategroupcontrols') {
 
     $template->process("admin/products/groupcontrol/updated.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editusers.cgi bugzilla-srcdir/editusers.cgi
--- bugzilla-srcdir.orig//editusers.cgi	2010-11-12 10:26:23.832939184 +0100
+++ bugzilla-srcdir/editusers.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -678,7 +678,7 @@ if ($action eq 'search') {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit(0);
 
 ###########################################################################
 # Helpers
diff -Naur bugzilla-srcdir.orig//editvalues.cgi bugzilla-srcdir/editvalues.cgi
--- bugzilla-srcdir.orig//editvalues.cgi	2010-11-12 10:26:23.852923792 +0100
+++ bugzilla-srcdir/editvalues.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -39,7 +39,7 @@ sub display_field_values {
     $vars->{'values'} = $vars->{'field'}->legal_values;
     $template->process("admin/fieldvalues/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 ######################################################################
@@ -81,7 +81,7 @@ if (!$cgi->param('field')) {
     $vars->{'fields'} = \@field_list;
     $template->process("admin/fieldvalues/select-field.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 # At this point, the field must be defined.
@@ -104,7 +104,7 @@ if ($action eq 'add') {
     $vars->{'token'} = issue_session_token('add_field_value');
     $template->process("admin/fieldvalues/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 #
@@ -145,7 +145,7 @@ if ($action eq 'del') {
     $template->process("admin/fieldvalues/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 
@@ -171,7 +171,7 @@ if ($action eq 'edit') {
     $template->process("admin/fieldvalues/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 
diff -Naur bugzilla-srcdir.orig//editversions.cgi bugzilla-srcdir/editversions.cgi
--- bugzilla-srcdir.orig//editversions.cgi	2010-11-12 10:26:23.461427610 +0100
+++ bugzilla-srcdir/editversions.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -80,7 +80,7 @@ unless ($product_name) {
 
     $template->process("admin/versions/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -95,7 +95,7 @@ unless ($action) {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -110,7 +110,7 @@ if ($action eq 'add') {
     $template->process("admin/versions/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -129,7 +129,7 @@ if ($action eq 'new') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -147,7 +147,7 @@ if ($action eq 'del') {
     $template->process("admin/versions/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -169,7 +169,7 @@ if ($action eq 'delete') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -188,7 +188,7 @@ if ($action eq 'edit') {
     $template->process("admin/versions/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 #
@@ -216,7 +216,7 @@ if ($action eq 'update') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit(1);
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editworkflow.cgi bugzilla-srcdir/editworkflow.cgi
--- bugzilla-srcdir.orig//editworkflow.cgi	2010-11-12 10:26:23.952922193 +0100
+++ bugzilla-srcdir/editworkflow.cgi	2010-11-12 10:28:19.721916586 +0100
@@ -67,7 +67,7 @@
 
     $template->process("admin/workflow/$filename.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 if ($action eq 'edit') {
diff -Naur bugzilla-srcdir.orig//email_in.pl bugzilla-srcdir/email_in.pl
--- bugzilla-srcdir.orig//email_in.pl	2010-11-12 10:26:39.776939670 +0100
+++ bugzilla-srcdir/email_in.pl	2010-11-12 10:28:19.721916586 +0100
@@ -377,7 +377,7 @@ sub die_handler {
     print STDERR "$msg\n";
     # We exit with a successful value, because we don't want the MTA
     # to *also* send a failure notice.
-    exit;
+    exit(1);
 }
 
 ###############
diff -Naur bugzilla-srcdir.orig//enter_bug.cgi bugzilla-srcdir/enter_bug.cgi
--- bugzilla-srcdir.orig//enter_bug.cgi	2010-11-12 10:26:23.481418058 +0100
+++ bugzilla-srcdir/enter_bug.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -115,7 +115,7 @@
             print $cgi->header();
             $template->process("global/choose-classification.html.tmpl", $vars)
                || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
         # If we come here, then there is only one classification available.
         $classification = $classifications[0]->{'object'}->name;
@@ -147,7 +147,7 @@
         print $cgi->header();
         $template->process("global/choose-product.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     } else {
         # Only one product exists.
         $product = $enterable_products[0];
diff -Naur bugzilla-srcdir.orig//importxml.pl bugzilla-srcdir/importxml.pl
--- bugzilla-srcdir.orig//importxml.pl	2010-11-12 10:26:39.432919924 +0100
+++ bugzilla-srcdir/importxml.pl	2010-11-12 10:28:19.725914769 +0100
@@ -163,7 +163,7 @@ sub Error {
     my @to = ( $params->{"maintainer"}, $exporter);
     Debug( $message, ERR_LEVEL );
     MailMessage( $subject, $message, @to );
-    exit;
+    exit(1);
 }
 
 # This subroutine handles flags for process_bug. It is generic in that
diff -Naur bugzilla-srcdir.orig//index.cgi bugzilla-srcdir/index.cgi
--- bugzilla-srcdir.orig//index.cgi	2010-11-12 10:26:25.268914746 +0100
+++ bugzilla-srcdir/index.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -64,7 +64,7 @@
     unless (Bugzilla->params->{'urlbase'}) {
         $template->process('welcome-admin.html.tmpl')
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
     # Inform the administrator about new releases, if any.
     $vars->{'release'} = Bugzilla::Update::get_notifications();
diff -Naur bugzilla-srcdir.orig//install-module.pl bugzilla-srcdir/install-module.pl
--- bugzilla-srcdir.orig//install-module.pl	2010-04-21 00:17:50.000000000 +0200
+++ bugzilla-srcdir/install-module.pl	2010-11-12 10:28:19.725914769 +0100
@@ -57,7 +57,7 @@ You cannot run this script when using ActiveState Perl. Please follow
 the instructions given by checksetup.pl to install missing Perl modules.
 
 END
-    exit;
+    exit(1);
 }
 
 pod2usage({ -verbose => 0 }) if (!%switch && !@ARGV);
@@ -66,14 +66,14 @@ set_cpan_config($switch{'global'});
 
 if ($switch{'show-config'}) {
     print Dumper($CPAN::Config);
-    exit;
+    exit(0);
 }
 
 check_cpan_requirements($original_dir, \@original_args);
 
 if ($switch{'shell'}) {
     CPAN::shell();
-    exit;
+    exit(0);
 }
 
 if ($switch{'all'} || $switch{'upgrade-all'}) {
diff -Naur bugzilla-srcdir.orig//post_bug.cgi bugzilla-srcdir/post_bug.cgi
--- bugzilla-srcdir.orig//post_bug.cgi	2010-11-12 10:26:39.724915541 +0100
+++ bugzilla-srcdir/post_bug.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -80,7 +80,7 @@
         print $cgi->header();
         $template->process("bug/create/confirm-create-dupe.html.tmpl", $vars)
            || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 }    
 
@@ -98,7 +98,7 @@
     print $cgi->header();
     $template->process("bug/create/make-template.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 umask 0;
diff -Naur bugzilla-srcdir.orig//process_bug.cgi bugzilla-srcdir/process_bug.cgi
--- bugzilla-srcdir.orig//process_bug.cgi	2010-11-12 10:26:25.605917372 +0100
+++ bugzilla-srcdir/process_bug.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -165,7 +165,7 @@ if (defined $cgi->param('delta_ts'))
         # Warn the user about the mid-air collision and ask them what to do.
         $template->process("bug/process/midair.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 }
 
@@ -397,7 +397,7 @@ elsif ($action eq 'next_bug' or $action eq 'same_bug') {
         }
         $template->process("bug/show.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit(1);
     }
 } elsif ($action ne 'nothing') {
     ThrowCodeError("invalid_post_bug_submit_action");
diff -Naur bugzilla-srcdir.orig//report.cgi bugzilla-srcdir/report.cgi
--- bugzilla-srcdir.orig//report.cgi	2010-11-12 10:26:24.124922158 +0100
+++ bugzilla-srcdir/report.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -43,7 +43,7 @@ if (grep(/^cmd-/, $cgi->param())) {
       ($params ? "&$params" : "");
 
     print $cgi->redirect($location);
-    exit;
+    exit(0);
 }
 
 use Bugzilla::Search;
@@ -59,7 +59,7 @@ if ($action eq "menu") {
     print $cgi->header();
     $template->process("reports/menu.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 my $col_field = $cgi->param('x_axis_field') || '';
@@ -306,7 +306,7 @@ disable_utf8() if ($format->{'ctype'} =~ /^image\//);
 $template->process("$format->{'template'}", $vars)
   || ThrowTemplateError($template->error());
 
-exit;
+exit(0);
 
 
 sub get_names {
diff -Naur bugzilla-srcdir.orig//request.cgi bugzilla-srcdir/request.cgi
--- bugzilla-srcdir.orig//request.cgi	2010-11-12 10:26:39.704930703 +0100
+++ bugzilla-srcdir/request.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -87,7 +87,7 @@
     $template->process('request/queue.html.tmpl', $vars)
       || ThrowTemplateError($template->error());
 }
-exit;
+exit(0);
 
 ################################################################################
 # Functions
diff -Naur bugzilla-srcdir.orig//sanitycheck.cgi bugzilla-srcdir/sanitycheck.cgi
--- bugzilla-srcdir.orig//sanitycheck.cgi	2010-11-12 10:26:23.932915961 +0100
+++ bugzilla-srcdir/sanitycheck.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -270,7 +270,7 @@ if ($cgi->param('rescanallBugMail')) {
         $template->process('global/footer.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
     }
-    exit;
+    exit(0);
 }
 
 ###########################################################################
diff -Naur bugzilla-srcdir.orig//showattachment.cgi bugzilla-srcdir/showattachment.cgi
--- bugzilla-srcdir.orig//showattachment.cgi	2010-11-12 10:26:24.060929332 +0100
+++ bugzilla-srcdir/showattachment.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -37,4 +37,4 @@
 print $cgi->redirect(-location=>"attachment.cgi?id=$id",
                      -status=>'301 Permanent Redirect');
 
-exit;
+exit(0);
diff -Naur bugzilla-srcdir.orig//show_bug.cgi bugzilla-srcdir/show_bug.cgi
--- bugzilla-srcdir.orig//show_bug.cgi	2010-11-12 10:26:39.684930804 +0100
+++ bugzilla-srcdir/show_bug.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -46,7 +46,7 @@ if (!$cgi->param('id') && $single) {
     print Bugzilla->cgi->header();
     $template->process("bug/choose.html.tmpl", $vars) ||
       ThrowTemplateError($template->error());
-    exit;
+    exit(1);
 }
 
 my $format = $template->get_format("bug/show", scalar $cgi->param('format'), 
diff -Naur bugzilla-srcdir.orig//testagent.cgi bugzilla-srcdir/testagent.cgi
--- bugzilla-srcdir.orig//testagent.cgi	2007-02-11 01:12:24.000000000 +0100
+++ bugzilla-srcdir/testagent.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -20,5 +20,5 @@
 use strict;
 print "content-type:text/plain\n\n";
 print "OK " . ($::ENV{MOD_PERL} || "mod_cgi") . "\n";
-exit;
+exit(0);
 
diff -Naur bugzilla-srcdir.orig//token.cgi bugzilla-srcdir/token.cgi
--- bugzilla-srcdir.orig//token.cgi	2010-11-12 10:26:39.388920267 +0100
+++ bugzilla-srcdir/token.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -166,7 +166,7 @@ if ($action eq 'reqpw') {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit(0);
 
 ################################################################################
 # Functions
diff -Naur bugzilla-srcdir.orig//votes.cgi bugzilla-srcdir/votes.cgi
--- bugzilla-srcdir.orig//votes.cgi	2010-11-12 10:26:23.872946250 +0100
+++ bugzilla-srcdir/votes.cgi	2010-11-12 10:28:19.725914769 +0100
@@ -47,4 +47,4 @@ else {
 }
 
 print $cgi->redirect('page.cgi?' . $cgi->query_string);
-exit;
+exit(0);
diff -Naur bugzilla-srcdir.orig//extensions/Voting/Extension.pm bugzilla-srcdir/extensions/Voting/Extension.pm
--- bugzilla-srcdir.orig//extensions/Voting/Extension.pm	2010-11-12 10:26:23.872946250 +0100
+++ bugzilla-srcdir/extensions/Voting/Extension.pm	2010-11-12 10:28:19.725914769 +0100
@@ -507,11 +507,11 @@ sub _update_votes {
             print $cgi->header();
             $template->process("voting/delete-all.html.tmpl", $vars)
               || ThrowTemplateError($template->error());
-            exit;
+            exit(1);
         }
         elsif ($cgi->param('delete_all_votes') == 0) {
             print $cgi->redirect("page.cgi?id=voting/user.html");
-            exit;
+            exit(0);
         }
     }
 
