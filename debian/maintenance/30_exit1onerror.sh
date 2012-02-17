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
if ! grep -q "exit 9;$" "$d/Bugzilla/Install/Localconfig.pm"; then
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
--- bugzilla-srcdir.orig//attachment.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/attachment.cgi	2012-02-17 19:05:56 +0100
@@ -133,7 +133,7 @@ else
   ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit 0;
 
 ################################################################################
 # Data Validation / Security Authorization
@@ -161,7 +161,7 @@ sub validateID {
         print $cgi->header();
         $template->process("attachment/choose.html.tmpl", $vars) ||
             ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
     
     my $attach_id = $cgi->param($param);
@@ -282,7 +282,7 @@ sub get_attachment {
                 unless ($userid && $valid_token) {
                     # Not a valid token.
                     print $cgi->redirect('-location' => correct_urlbase() . $path);
-                    exit;
+                    exit 0;
                 }
                 # Change current user without creating cookies.
                 Bugzilla->set_user(new Bugzilla::User($userid));
@@ -308,7 +308,7 @@ sub get_attachment {
             if (all_attachments_are_public(\%attachments)) {
                 # No need for a token; redirect to attachment base.
                 print $cgi->redirect(-location => $attachbase . $path);
-                exit;
+                exit 0;
             } else {
                 # Make sure the user can view the attachment.
                 foreach my $field_name (@field_names) {
@@ -317,7 +317,7 @@ sub get_attachment {
                 # Create a token and redirect.
                 my $token = url_quote(issue_session_token(pack_token_data(\%attachments)));
                 print $cgi->redirect(-location => $attachbase . "$path&t=$token");
-                exit;
+                exit 0;
             }
         }
     } else {
@@ -682,7 +682,7 @@ sub update {
                 # Warn the user about the mid-air collision and ask them what to do.
                 $template->process("attachment/midair.html.tmpl", $vars)
                   || ThrowTemplateError($template->error());
-                exit;
+                exit 0;
             }
         }
     }
diff -Naur bugzilla-srcdir.orig//buglist.cgi bugzilla-srcdir/buglist.cgi
--- bugzilla-srcdir.orig//buglist.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/buglist.cgi	2012-02-17 19:05:56 +0100
@@ -461,7 +461,7 @@ if ($cmdtype eq "dorem") {
         $vars->{'url'} = "buglist.cgi?newquery=" . url_quote($buffer) . "&cmdtype=doit&remtype=asnamed&newqueryname=" . url_quote($qname);
         $template->process("global/message.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 }
 elsif (($cmdtype eq "doit") && defined $cgi->param('remtype')) {
@@ -525,7 +525,7 @@ elsif (($cmdtype eq "doit") && defined $cgi->param('remtype')) {
         print $cgi->header();
         $template->process("global/message.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 }
 
diff -Naur bugzilla-srcdir.orig//Bugzilla/Auth/Login/CGI.pm bugzilla-srcdir/Bugzilla/Auth/Login/CGI.pm
--- bugzilla-srcdir.orig//Bugzilla/Auth/Login/CGI.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Auth/Login/CGI.pm	2012-02-17 19:05:56 +0100
@@ -65,7 +65,7 @@ sub fail_nodata {
     $template->process("account/auth/login.html.tmpl",
                        { 'target' => $cgi->url(-relative=>1) }) 
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 1;
diff -Naur bugzilla-srcdir.orig//Bugzilla/Bug.pm bugzilla-srcdir/Bugzilla/Bug.pm
--- bugzilla-srcdir.orig//Bugzilla/Bug.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Bug.pm	2012-02-17 19:05:56 +0100
@@ -1617,7 +1617,7 @@ sub _check_dup_id {
             print $cgi->header();
             $template->process("bug/process/confirm-duplicate.html.tmpl", $vars)
               || ThrowTemplateError($template->error());
-            exit;
+            exit 0;
         }
     }
 
@@ -2498,7 +2498,7 @@ sub _set_product {
             my $template = Bugzilla->template;
             $template->process("bug/process/verify-new-product.html.tmpl",
                 \%vars) || ThrowTemplateError($template->error());
-            exit;
+            exit 0;
         }
     }
     else {
diff -Naur bugzilla-srcdir.orig//Bugzilla/CGI.pm bugzilla-srcdir/Bugzilla/CGI.pm
--- bugzilla-srcdir.orig//Bugzilla/CGI.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/CGI.pm	2012-02-17 19:05:56 +0100
@@ -455,7 +455,7 @@ sub redirect_search_url {
     my $uri_length = length($self->self_url());
     if ($self->request_method() ne 'POST' or $uri_length < CGI_URI_LIMIT) {
         print $self->redirect(-url => $self->self_url());
-        exit;
+        exit 0;
     }
 }
 
@@ -478,7 +478,7 @@ sub redirect_to_https {
 
     # When using XML-RPC with mod_perl, we need the headers sent immediately.
     $self->r->rflush if $ENV{MOD_PERL};
-    exit;
+    exit 0;
 }
 
 # Redirect to the urlbase version of the current URL.
@@ -486,7 +486,7 @@ sub redirect_to_urlbase {
     my $self = shift;
     my $path = $self->url('-path_info' => 1, '-query' => 1, '-relative' => 1);
     print $self->redirect('-location' => correct_urlbase() . $path);
-    exit;
+    exit 0;
 }
 
 sub url_is_attachment_base {
diff -Naur bugzilla-srcdir.orig//Bugzilla/Install/Util.pm bugzilla-srcdir/Bugzilla/Install/Util.pm
--- bugzilla-srcdir.orig//Bugzilla/Install/Util.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Install/Util.pm	2012-02-17 19:05:56 +0100
@@ -531,7 +531,7 @@ sub vers_cmp {
 sub no_checksetup_from_cgi {
     print "Content-Type: text/html; charset=UTF-8\r\n\r\n";
     print install_string('no_checksetup_from_cgi');
-    exit;
+    exit 0;
 }
 
 ######################
diff -Naur bugzilla-srcdir.orig//Bugzilla/Install/Localconfig.pm bugzilla-srcdir/Bugzilla/Install/Localconfig.pm
--- bugzilla-srcdir.orig//Bugzilla/Install/Localconfig.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Install/Localconfig.pm	2012-02-17 19:05:56 +0100
@@ -279,7 +279,7 @@ sub update_localconfig {
         print colored(install_string('lc_new_vars', { localconfig => $filename,
                                                       new_vars => wrap_hard($newstuff, 70) }),
                       COLOR_ERROR), "\n";
-        exit;
+        exit 9;
     }
 
     # Reset the cache for Bugzilla->localconfig so that it will be re-read
diff -Naur bugzilla-srcdir.orig//Bugzilla/Search/Quicksearch.pm bugzilla-srcdir/Bugzilla/Search/Quicksearch.pm
--- bugzilla-srcdir.orig//Bugzilla/Search/Quicksearch.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Search/Quicksearch.pm	2012-02-17 19:05:56 +0100
@@ -234,7 +234,7 @@ sub _bug_numbers_only {
         # Single bug number; shortcut to show_bug.cgi.
         print $cgi->redirect(
             -uri => correct_urlbase() . "show_bug.cgi?id=$searchstring");
-        exit;
+        exit 0;
     }
     else {
         # List of bug numbers.
@@ -255,7 +255,7 @@ sub _handle_alias {
             $alias = url_quote($alias);
             print Bugzilla->cgi->redirect(
                 -uri => correct_urlbase() . "show_bug.cgi?id=$alias");
-            exit;
+            exit 0;
         }
     }
 }
diff -Naur bugzilla-srcdir.orig//Bugzilla/Error.pm bugzilla-srcdir/Bugzilla/Error.pm
--- bugzilla-srcdir.orig//Bugzilla/Error.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Error.pm	2012-02-17 19:05:56 +0100
@@ -145,7 +145,7 @@ sub _throw_error {
             }
         }
     }
-    exit;
+    exit 1;
 }
 
 sub ThrowUserError {
@@ -209,7 +209,7 @@ sub ThrowTemplateError {
         </tt>
 END
     }
-    exit;
+    exit 1;
 }
 
 1;
diff -Naur bugzilla-srcdir.orig//Bugzilla/Token.pm bugzilla-srcdir/Bugzilla/Token.pm
--- bugzilla-srcdir.orig//Bugzilla/Token.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/Token.pm	2012-02-17 19:05:56 +0100
@@ -222,7 +222,7 @@ sub check_hash_token {
         print Bugzilla->cgi->header();
         $template->process('global/confirm-action.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 
     # If we come here, then the token is valid and not too old.
@@ -403,7 +403,7 @@ sub check_token_data {
 
         $template->process('admin/confirm-action.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
     return 1;
 }
diff -Naur bugzilla-srcdir.orig//Bugzilla/User.pm bugzilla-srcdir/Bugzilla/User.pm
--- bugzilla-srcdir.orig//Bugzilla/User.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla/User.pm	2012-02-17 19:05:56 +0100
@@ -1613,7 +1613,7 @@ sub match_field {
 
     $template->process("global/confirm-user-match.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 
 }
 

diff -Naur bugzilla-srcdir.orig//contrib/recode.pl bugzilla-srcdir/contrib/recode.pl
--- bugzilla-srcdir.orig//contrib/recode.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/contrib/recode.pl	2012-02-17 19:05:56 +0100
@@ -105,7 +105,7 @@ Encode::Detect, run the following command:
   $^X install-module.pl Encode::Detect
 
 EOT
-        exit;
+        exit 1;
     }
 }
 
diff -Naur bugzilla-srcdir.orig//contrib/sendbugmail.pl bugzilla-srcdir/contrib/sendbugmail.pl
--- bugzilla-srcdir.orig//contrib/sendbugmail.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/contrib/sendbugmail.pl	2012-02-17 19:05:56 +0100
@@ -23,7 +23,7 @@ my $dbh = Bugzilla->dbh;
 
 sub usage {
     print STDERR "Usage: $0 bug_id user_email\n";
-    exit;
+    exit 1;
 }
 
 if (($#ARGV < 1) || ($#ARGV > 2)) {
diff -Naur bugzilla-srcdir.orig//contrib/syncLDAP.pl bugzilla-srcdir/contrib/syncLDAP.pl
--- bugzilla-srcdir.orig//contrib/syncLDAP.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/contrib/syncLDAP.pl	2012-02-17 19:05:56 +0100
@@ -70,7 +70,7 @@ foreach my $arg (@ARGV)
          print " -c No create, don't create users, which are in LDAP but not in Bugzilla\n";
          print " -q Quiet mode, give less output\n";
          print "\n";
-         exit;
+         exit 1;
    }
 }
 
@@ -94,7 +94,7 @@ foreach my $login_name (keys %bugzilla_users) {
 my $LDAPserver = Bugzilla->params->{"LDAPserver"};
 if ($LDAPserver eq "") {
    print "No LDAP server defined in bugzilla preferences.\n";
-   exit;
+   exit 1;
 }
 
 my $LDAPconn;
@@ -111,7 +111,7 @@ if($LDAPserver =~ /:\/\//) {
 
 if(!$LDAPconn) {
    print "Connecting to LDAP server failed. Check LDAPserver setting.\n";
-   exit;
+   exit 1;
 }
 my $mesg;
 if (Bugzilla->params->{"LDAPbinddn"}) {
@@ -123,7 +123,7 @@ else {
 }
 if($mesg->code) {
    print "Binding to LDAP server failed: " . $mesg->error . "\nCheck LDAPbinddn setting.\n";
-   exit;
+   exit 1;
 }
 
 # We've got our anonymous bind;  let's look up the users.
@@ -135,7 +135,7 @@ $mesg = $LDAPconn->search( base   => Bugzilla->params->{"LDAPBaseDN"},
 
 if(! $mesg->count) {
    print "LDAP lookup failure. Check LDAPBaseDN setting.\n";
-   exit;
+   exit 1;
 }
    
 my %val = %{ $mesg->as_struct };
diff -Naur bugzilla-srcdir.orig//extensions/Voting/Extension.pm bugzilla-srcdir/extensions/Voting/Extension.pm
--- bugzilla-srcdir.orig//extensions/Voting/Extension.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/extensions/Voting/Extension.pm	2012-02-17 19:05:56 +0100
@@ -522,11 +522,11 @@ sub _update_votes {
             print $cgi->header();
             $template->process("voting/delete-all.html.tmpl", $vars)
               || ThrowTemplateError($template->error());
-            exit;
+            exit 0;
         }
         elsif ($cgi->param('delete_all_votes') == 0) {
             print $cgi->redirect("page.cgi?id=voting/user.html");
-            exit;
+            exit 0;
         }
     }
 
diff -Naur bugzilla-srcdir.orig//Bugzilla.pm bugzilla-srcdir/Bugzilla.pm
--- bugzilla-srcdir.orig//Bugzilla.pm	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/Bugzilla.pm	2012-02-17 19:05:56 +0100
@@ -145,7 +145,7 @@ sub init_page {
         if (!i_am_cgi()
             && grep { $_ eq $script } SHUTDOWNHTML_EXIT_SILENTLY)
         {
-            exit;
+            exit 0;
         }
 
         # For security reasons, log out users when Bugzilla is down.
@@ -184,7 +184,7 @@ sub init_page {
         $template->process("global/message.$extension.tmpl", $vars, \$t_output)
             || ThrowTemplateError($template->error);
         print $t_output . "\n";
-        exit;
+        exit 0;
     }
 }
 
diff -Naur bugzilla-srcdir.orig//chart.cgi bugzilla-srcdir/chart.cgi
--- bugzilla-srcdir.orig//chart.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/chart.cgi	2012-02-17 19:05:56 +0100
@@ -76,7 +76,7 @@ if (grep(/^cmd-/, $cgi->param())) {
     my $params = $cgi->canonicalise_query("format", "ctype", "action");
     print $cgi->redirect("query.cgi?format=" . $cgi->param('query_format') .
                                                ($params ? "&$params" : ""));
-    exit;
+    exit 1;
 }
 
 my $action = $cgi->param('action');
@@ -99,7 +99,7 @@ $action ||= "assemble";
 if ($action eq "search") {
     my $params = $cgi->canonicalise_query("format", "ctype", "action");
     print $cgi->redirect("buglist.cgi" . ($params ? "?$params" : ""));
-    exit;
+    exit 1;
 }
 
 $user->in_group(Bugzilla->params->{"chartgroup"})
@@ -234,7 +234,7 @@ else {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit 0;
 
 # Find any selected series and return either the first or all of them.
 sub getAndValidateSeriesIDs {

diff -Naur bugzilla-srcdir.orig//checksetup.pl bugzilla-srcdir/checksetup.pl
--- bugzilla-srcdir.orig//checksetup.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/checksetup.pl	2012-02-17 19:05:56 +0100
@@ -81,14 +81,14 @@ my $answers_file = $ARGV[0];
 my $silent = $answers_file && !$switch{'verbose'};
 
 print(install_string('header', get_version_and_os()) . "\n") unless $silent;
-exit if $switch{'version'};
+exit 0 if $switch{'version'};
 # Check required --MODULES--
 my $module_results = check_requirements(!$silent);
 Bugzilla::Install::Requirements::print_module_instructions(
     $module_results, !$silent);
-exit if !$module_results->{pass};
+exit 1 if !$module_results->{pass};
 # Break out if checking the modules is all we have been asked to do.
-exit if $switch{'check-modules'};
+exit 0 if $switch{'check-modules'};
 
 ###########################################################################
 # Load Bugzilla Modules
diff -Naur bugzilla-srcdir.orig//colchange.cgi bugzilla-srcdir/colchange.cgi
--- bugzilla-srcdir.orig//colchange.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/colchange.cgi	2012-02-17 19:05:56 +0100
@@ -165,12 +165,12 @@ if (defined $cgi->param('rememberedquery')) {
     }
     else {
       print $cgi->redirect($vars->{'redirect_url'});
-      exit;
+      exit 0;
     }
     
     $template->process("global/message.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if (defined $cgi->param('columnlist')) {
diff -Naur bugzilla-srcdir.orig//config.cgi bugzilla-srcdir/config.cgi
--- bugzilla-srcdir.orig//config.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/config.cgi	2012-02-17 19:05:56 +0100
@@ -162,5 +162,5 @@ sub display_data {
                             -type => $format->{'ctype'});
         print $output;
     }
-    exit;
+    exit 0;
 }
diff -Naur bugzilla-srcdir.orig//createaccount.cgi bugzilla-srcdir/createaccount.cgi
--- bugzilla-srcdir.orig//createaccount.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/createaccount.cgi	2012-02-17 19:05:56 +0100
@@ -57,7 +57,7 @@ if (defined($login)) {
 
     $template->process("account/created.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 # Show the standard "would you like to create an account?" form.
diff -Naur bugzilla-srcdir.orig//describecomponents.cgi bugzilla-srcdir/describecomponents.cgi
--- bugzilla-srcdir.orig//describecomponents.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/describecomponents.cgi	2012-02-17 19:05:56 +0100
@@ -70,7 +70,7 @@ unless ($product && $user->can_access_product($product->name)) {
 
         $template->process("global/choose-product.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 
     # If there is only one product available and the user didn't specify
diff -Naur bugzilla-srcdir.orig//editclassifications.cgi bugzilla-srcdir/editclassifications.cgi
--- bugzilla-srcdir.orig//editclassifications.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editclassifications.cgi	2012-02-17 19:05:56 +0100
@@ -51,7 +51,7 @@ sub LoadTemplate {
     print $cgi->header();
     $template->process("admin/classifications/$action.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
diff -Naur bugzilla-srcdir.orig//editcomponents.cgi bugzilla-srcdir/editcomponents.cgi
--- bugzilla-srcdir.orig//editcomponents.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editcomponents.cgi	2012-02-17 19:05:56 +0100
@@ -80,7 +80,7 @@ unless ($product_name) {
 
     $template->process("admin/components/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -94,7 +94,7 @@ unless ($action) {
     $vars->{'product'} = $product;
     $template->process("admin/components/list.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -108,7 +108,7 @@ if ($action eq 'add') {
     $vars->{'product'} = $product;
     $template->process("admin/components/create.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -149,7 +149,7 @@ if ($action eq 'new') {
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -166,7 +166,7 @@ if ($action eq 'del') {
 
     $template->process("admin/components/confirm-delete.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -188,7 +188,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -210,7 +210,7 @@ if ($action eq 'edit') {
 
     $template->process("admin/components/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -252,7 +252,7 @@ if ($action eq 'update') {
 
     $template->process("admin/components/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editflagtypes.cgi bugzilla-srcdir/editflagtypes.cgi
--- bugzilla-srcdir.orig//editflagtypes.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editflagtypes.cgi	2012-02-17 19:05:56 +0100
@@ -148,7 +148,7 @@ if (my ($category_action) = grep { $_ =~ /^categoryAction-(?:\w+)$/ } $cgi->para
 
     $template->process("admin/flag-type/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'list') {
@@ -209,7 +209,7 @@ if ($action eq 'list') {
 
     $template->process("admin/flag-type/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'enter') {
@@ -230,7 +230,7 @@ if ($action eq 'enter') {
 
     $template->process("admin/flag-type/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'edit' || $action eq 'copy') {
@@ -262,7 +262,7 @@ if ($action eq 'edit' || $action eq 'copy') {
 
     $template->process("admin/flag-type/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'insert') {
@@ -315,7 +315,7 @@ if ($action eq 'insert') {
 
     $template->process("admin/flag-type/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'update') {
@@ -378,7 +378,7 @@ if ($action eq 'update') {
 
     $template->process("admin/flag-type/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'confirmdelete') {
@@ -390,7 +390,7 @@ if ($action eq 'confirmdelete') {
 
     $template->process("admin/flag-type/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'delete') {
@@ -412,7 +412,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/flag-type/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'deactivate') {
@@ -435,7 +435,7 @@ if ($action eq 'deactivate') {
 
     $template->process("admin/flag-type/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 ThrowUserError('unknown_action', {action => $action});
diff -Naur bugzilla-srcdir.orig//editgroups.cgi bugzilla-srcdir/editgroups.cgi
--- bugzilla-srcdir.orig//editgroups.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editgroups.cgi	2012-02-17 19:05:56 +0100
@@ -157,7 +157,7 @@ unless ($action) {
     print $cgi->header();
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -179,7 +179,7 @@ if ($action eq 'changeform') {
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -194,7 +194,7 @@ if ($action eq 'add') {
     $template->process("admin/groups/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
     
-    exit;
+    exit 0;
 }
 
 
@@ -231,7 +231,7 @@ if ($action eq 'new') {
     print $cgi->header();
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -256,7 +256,7 @@ if ($action eq 'del') {
     $template->process("admin/groups/delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
     
-    exit;
+    exit 0;
 }
 
 #
@@ -282,7 +282,7 @@ if ($action eq 'delete') {
     print $cgi->header();
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -304,7 +304,7 @@ if ($action eq 'postchanges') {
     print $cgi->header();
     $template->process("admin/groups/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'confirm_remove') {
@@ -314,7 +314,7 @@ if ($action eq 'confirm_remove') {
     $vars->{'token'} = issue_session_token('remove_group_members');
     $template->process('admin/groups/confirm-remove.html.tmpl', $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'remove_regexp') {
@@ -354,7 +354,7 @@ if ($action eq 'remove_regexp') {
     $template->process("admin/groups/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editkeywords.cgi bugzilla-srcdir/editkeywords.cgi
--- bugzilla-srcdir.orig//editkeywords.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editkeywords.cgi	2012-02-17 19:05:56 +0100
@@ -62,7 +62,7 @@ if ($action eq "") {
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
     
 
@@ -74,7 +74,7 @@ if ($action eq 'add') {
     $template->process("admin/keywords/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -98,7 +98,7 @@ if ($action eq 'new') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 
@@ -118,7 +118,7 @@ if ($action eq 'edit') {
     print $cgi->header();
     $template->process("admin/keywords/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 
@@ -148,7 +148,7 @@ if ($action eq 'update') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'del') {
@@ -161,7 +161,7 @@ if ($action eq 'del') {
     print $cgi->header();
     $template->process("admin/keywords/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'delete') {
@@ -181,7 +181,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/keywords/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 ThrowUserError('unknown_action', {action => $action});
diff -Naur bugzilla-srcdir.orig//editmilestones.cgi bugzilla-srcdir/editmilestones.cgi
--- bugzilla-srcdir.orig//editmilestones.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editmilestones.cgi	2012-02-17 19:05:56 +0100
@@ -78,7 +78,7 @@ unless ($product_name) {
 
     $template->process("admin/milestones/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -93,7 +93,7 @@ unless ($action) {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -107,7 +107,7 @@ if ($action eq 'add') {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -128,7 +128,7 @@ if ($action eq 'new') {
     $vars->{'product'} = $product;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -152,7 +152,7 @@ if ($action eq 'del') {
 
     $template->process("admin/milestones/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -173,7 +173,7 @@ if ($action eq 'delete') {
 
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -193,7 +193,7 @@ if ($action eq 'edit') {
 
     $template->process("admin/milestones/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -222,7 +222,7 @@ if ($action eq 'update') {
     $vars->{'changes'} = $changes;
     $template->process("admin/milestones/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editproducts.cgi bugzilla-srcdir/editproducts.cgi
--- bugzilla-srcdir.orig//editproducts.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editproducts.cgi	2012-02-17 19:05:56 +0100
@@ -95,7 +95,7 @@ if (Bugzilla->params->{'useclassification'}
 
     $template->process("admin/products/list-classifications.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 
@@ -129,7 +129,7 @@ if (!$action && !$product_name) {
 
     $template->process("admin/products/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 
@@ -158,7 +158,7 @@ if ($action eq 'add') {
     $template->process("admin/products/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 
@@ -199,7 +199,7 @@ if ($action eq 'new') {
 
     $template->process("admin/products/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -221,7 +221,7 @@ if ($action eq 'del') {
     
     $template->process("admin/products/confirm-delete.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -258,7 +258,7 @@ if ($action eq 'delete') {
         $template->process("admin/products/list.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
     }
-    exit;
+    exit 0;
 }
 
 #
@@ -279,7 +279,7 @@ if ($action eq 'edit' || (!$action && $product_name)) {
 
     $template->process("admin/products/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -310,7 +310,7 @@ if ($action eq 'update') {
 
     $template->process("admin/products/updated.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -325,7 +325,7 @@ if ($action eq 'editgroupcontrols') {
 
     $template->process("admin/products/groupcontrol/edit.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 #
@@ -394,7 +394,7 @@ if ($action eq 'updategroupcontrols') {
             $vars->{'mandatory_groups'} = $mandatory_groups;
             $template->process("admin/products/groupcontrol/confirm-edit.html.tmpl", $vars)
                 || ThrowTemplateError($template->error());
-            exit;
+            exit 0;
         }
     }
 
@@ -419,7 +419,7 @@ if ($action eq 'updategroupcontrols') {
 
     $template->process("admin/products/groupcontrol/updated.html.tmpl", $vars)
         || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editusers.cgi bugzilla-srcdir/editusers.cgi
--- bugzilla-srcdir.orig//editusers.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editusers.cgi	2012-02-17 19:05:56 +0100
@@ -682,7 +682,7 @@ if ($action eq 'search') {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit 0;
 
 ###########################################################################
 # Helpers
diff -Naur bugzilla-srcdir.orig//editversions.cgi bugzilla-srcdir/editversions.cgi
--- bugzilla-srcdir.orig//editversions.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editversions.cgi	2012-02-17 19:05:56 +0100
@@ -81,7 +81,7 @@ unless ($product_name) {
 
     $template->process("admin/versions/select-product.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 my $product = $user->check_can_admin_product($product_name);
@@ -96,7 +96,7 @@ unless ($action) {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -111,7 +111,7 @@ if ($action eq 'add') {
     $template->process("admin/versions/create.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -130,7 +130,7 @@ if ($action eq 'new') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -148,7 +148,7 @@ if ($action eq 'del') {
     $template->process("admin/versions/confirm-delete.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -170,7 +170,7 @@ if ($action eq 'delete') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -189,7 +189,7 @@ if ($action eq 'edit') {
     $template->process("admin/versions/edit.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 #
@@ -218,7 +218,7 @@ if ($action eq 'update') {
     $template->process("admin/versions/list.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
 
-    exit;
+    exit 0;
 }
 
 # No valid action found
diff -Naur bugzilla-srcdir.orig//editworkflow.cgi bugzilla-srcdir/editworkflow.cgi
--- bugzilla-srcdir.orig//editworkflow.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/editworkflow.cgi	2012-02-17 19:05:56 +0100
@@ -67,7 +67,7 @@ sub load_template {
 
     $template->process("admin/workflow/$filename.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 if ($action eq 'edit') {
diff -Naur bugzilla-srcdir.orig//email_in.pl bugzilla-srcdir/email_in.pl
--- bugzilla-srcdir.orig//email_in.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/email_in.pl	2012-02-17 19:05:56 +0100
@@ -91,7 +91,7 @@ sub parse_mail {
     my $auto_submitted = $input_email->header('Auto-Submitted') || '';
     if ($summary =~ /out of( the)? office/i || $auto_submitted eq 'auto-replied') {
         debug_print("Automatic reply detected: $summary");
-        exit;
+        exit 0;
     }
 
     my ($body, $attachments) = get_body_and_attachments($input_email);
@@ -394,7 +394,7 @@ sub die_handler {
     print STDERR "$msg\n";
     # We exit with a successful value, because we don't want the MTA
     # to *also* send a failure notice.
-    exit;
+    exit 0;
 }
 
 ###############
diff -Naur bugzilla-srcdir.orig//enter_bug.cgi bugzilla-srcdir/enter_bug.cgi
--- bugzilla-srcdir.orig//enter_bug.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/enter_bug.cgi	2012-02-17 19:05:56 +0100
@@ -115,7 +115,7 @@ if ($product_name eq '') {
             print $cgi->header();
             $template->process("global/choose-classification.html.tmpl", $vars)
                || ThrowTemplateError($template->error());
-            exit;
+            exit 0;
         }
         # If we come here, then there is only one classification available.
         $classification = $classifications[0]->{'object'}->name;
@@ -147,7 +147,7 @@ if ($product_name eq '') {
         print $cgi->header();
         $template->process("global/choose-product.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     } else {
         # Only one product exists.
         $product = $enterable_products[0];
diff -Naur bugzilla-srcdir.orig//importxml.pl bugzilla-srcdir/importxml.pl
--- bugzilla-srcdir.orig//importxml.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/importxml.pl	2012-02-17 19:05:56 +0100
@@ -164,7 +164,7 @@ sub Error {
     my @to = ( $params->{"maintainer"}, $exporter);
     Debug( $message, ERR_LEVEL );
     MailMessage( $subject, $message, @to );
-    exit;
+    exit 0;
 }
 
 # This subroutine handles flags for process_bug. It is generic in that
diff -Naur bugzilla-srcdir.orig//index.cgi bugzilla-srcdir/index.cgi
--- bugzilla-srcdir.orig//index.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/index.cgi	2012-02-17 19:05:56 +0100
@@ -64,7 +64,7 @@ if ($user->in_group('admin')) {
     unless (Bugzilla->params->{'urlbase'}) {
         $template->process('welcome-admin.html.tmpl')
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
     # Inform the administrator about new releases, if any.
     $vars->{'release'} = Bugzilla::Update::get_notifications();
diff -Naur bugzilla-srcdir.orig//install-module.pl bugzilla-srcdir/install-module.pl
--- bugzilla-srcdir.orig//install-module.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/install-module.pl	2012-02-17 19:05:56 +0100
@@ -57,7 +57,7 @@ You cannot run this script when using ActiveState Perl. Please follow
 the instructions given by checksetup.pl to install missing Perl modules.
 
 END
-    exit;
+    exit 1;
 }
 
 pod2usage({ -verbose => 0 }) if (!%switch && !@ARGV);
@@ -66,14 +66,14 @@ set_cpan_config($switch{'global'});
 
 if ($switch{'show-config'}) {
     print Dumper($CPAN::Config);
-    exit;
+    exit 0;
 }
 
 check_cpan_requirements($original_dir, \@original_args);
 
 if ($switch{'shell'}) {
     CPAN::shell();
-    exit;
+    exit 0;
 }
 
 if ($switch{'all'} || $switch{'upgrade-all'}) {
diff -Naur bugzilla-srcdir.orig//post_bug.cgi bugzilla-srcdir/post_bug.cgi
--- bugzilla-srcdir.orig//post_bug.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/post_bug.cgi	2012-02-17 19:05:56 +0100
@@ -57,7 +57,7 @@ my $vars = {};
 # redirect to enter_bug if no field is passed.
 unless ($cgi->param()) {
     print $cgi->redirect(correct_urlbase() . 'enter_bug.cgi');
-    exit;
+    exit 1;
 }
 
 # Detect if the user already used the same form to submit a bug
@@ -78,7 +78,7 @@ if (defined $cgi->param('maketemplate')) {
     print $cgi->header();
     $template->process("bug/create/make-template.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 umask 0;
diff -Naur bugzilla-srcdir.orig//process_bug.cgi bugzilla-srcdir/process_bug.cgi
--- bugzilla-srcdir.orig//process_bug.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/process_bug.cgi	2012-02-17 19:05:56 +0100
@@ -163,7 +163,7 @@ if (defined $cgi->param('delta_ts'))
         # Warn the user about the mid-air collision and ask them what to do.
         $template->process("bug/process/midair.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 }
 
@@ -408,7 +408,7 @@ elsif ($action eq 'next_bug' or $action eq 'same_bug') {
         }
         $template->process("bug/show.html.tmpl", $vars)
           || ThrowTemplateError($template->error());
-        exit;
+        exit 0;
     }
 } elsif ($action ne 'nothing') {
     ThrowCodeError("invalid_post_bug_submit_action");
diff -Naur bugzilla-srcdir.orig//relogin.cgi bugzilla-srcdir/relogin.cgi
--- bugzilla-srcdir.orig//relogin.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/relogin.cgi	2012-02-17 19:05:56 +0100
@@ -45,7 +45,7 @@ my $target;
 if (!$action) {
     # redirect to index.cgi if no action is defined.
     print $cgi->redirect(correct_urlbase() . 'index.cgi');
-    exit;
+    exit 1;
 }
 # prepare-sudo: Display the sudo information & login page
 elsif ($action eq 'prepare-sudo') {
diff -Naur bugzilla-srcdir.orig//report.cgi bugzilla-srcdir/report.cgi
--- bugzilla-srcdir.orig//report.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/report.cgi	2012-02-17 19:05:56 +0100
@@ -45,7 +45,7 @@ if (grep(/^cmd-/, $cgi->param())) {
       ($params ? "&$params" : "");
 
     print $cgi->redirect($location);
-    exit;
+    exit 0;
 }
 
 Bugzilla->login();
@@ -59,7 +59,7 @@ if ($action eq "menu") {
     print $cgi->header();
     $template->process("reports/menu.html.tmpl", $vars)
       || ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 my $col_field = $cgi->param('x_axis_field') || '';
diff -Naur bugzilla-srcdir.orig//request.cgi bugzilla-srcdir/request.cgi
--- bugzilla-srcdir.orig//request.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/request.cgi	2012-02-17 19:05:56 +0100
@@ -87,7 +87,7 @@ else {
     $template->process('request/queue.html.tmpl', $vars)
       || ThrowTemplateError($template->error());
 }
-exit;
+exit 0;
 
 ################################################################################
 # Functions
diff -Naur bugzilla-srcdir.orig//sanitycheck.cgi bugzilla-srcdir/sanitycheck.cgi
--- bugzilla-srcdir.orig//sanitycheck.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/sanitycheck.cgi	2012-02-17 19:05:56 +0100
@@ -270,7 +270,7 @@ if ($cgi->param('rescanallBugMail')) {
         $template->process('global/footer.html.tmpl', $vars)
           || ThrowTemplateError($template->error());
     }
-    exit;
+    exit 0;
 }
 
 ###########################################################################
diff -Naur bugzilla-srcdir.orig//show_bug.cgi bugzilla-srcdir/show_bug.cgi
--- bugzilla-srcdir.orig//show_bug.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/show_bug.cgi	2012-02-17 19:05:56 +0100
@@ -46,7 +46,7 @@ if (!$cgi->param('id') && $single) {
     print Bugzilla->cgi->header();
     $template->process("bug/choose.html.tmpl", $vars) ||
       ThrowTemplateError($template->error());
-    exit;
+    exit 0;
 }
 
 my $format = $template->get_format("bug/show", scalar $cgi->param('format'), 
diff -Naur bugzilla-srcdir.orig//testagent.cgi bugzilla-srcdir/testagent.cgi
--- bugzilla-srcdir.orig//testagent.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/testagent.cgi	2012-02-17 19:05:56 +0100
@@ -20,5 +20,5 @@
 use strict;
 print "content-type:text/plain\n\n";
 print "OK " . ($::ENV{MOD_PERL} || "mod_cgi") . "\n";
-exit;
+exit 0;
 
diff -Naur bugzilla-srcdir.orig//token.cgi bugzilla-srcdir/token.cgi
--- bugzilla-srcdir.orig//token.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/token.cgi	2012-02-17 19:05:56 +0100
@@ -166,7 +166,7 @@ if ($action eq 'reqpw') {
     ThrowUserError('unknown_action', {action => $action});
 }
 
-exit;
+exit 0;
 
 ################################################################################
 # Functions
diff -Naur bugzilla-srcdir.orig//votes.cgi bugzilla-srcdir/votes.cgi
--- bugzilla-srcdir.orig//votes.cgi	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/votes.cgi	2012-02-17 19:05:56 +0100
@@ -47,4 +47,4 @@ else {
 }
 
 print $cgi->redirect('page.cgi?' . $cgi->query_string);
-exit;
+exit 0;
diff -Naur bugzilla-srcdir.orig//whineatnews.pl bugzilla-srcdir/whineatnews.pl
--- bugzilla-srcdir.orig//whineatnews.pl	2012-02-17 19:03:56 +0100
+++ bugzilla-srcdir/whineatnews.pl	2012-02-17 19:05:56 +0100
@@ -39,7 +39,7 @@ use Bugzilla::Util;
 use Bugzilla::User;
 
 # Whining is disabled if whinedays is zero
-exit unless Bugzilla->params->{'whinedays'} >= 1;
+exit 1 unless Bugzilla->params->{'whinedays'} >= 1;
 
 my $dbh = Bugzilla->dbh;
 my $query = q{SELECT bug_id, short_desc, login_name
