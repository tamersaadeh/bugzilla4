#!/usr/bin/perl -wT
# -*- Mode: perl; indent-tabs-mode: nil; cperl-indent-level: 4 -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the Bugzilla Bug Tracking System.
#
# The Initial Developer of the Original Code is Albert Ting
#
# Contributor(s): Albert Ting <alt@sonic.net>
#                 Max Kanat-Alexander <mkanat@bugzilla.org>
#                 Frédéric Buclin <LpSolit@gmail.com>


use strict;
use lib qw(. lib);

use Bugzilla;
use Bugzilla::Constants;
use Bugzilla::Util;
use Bugzilla::Error;
use Bugzilla::Classification;
use Bugzilla::Token;

my $dbh = Bugzilla->dbh;
my $cgi = Bugzilla->cgi;
my $template = Bugzilla->template;
local our $vars = {};

sub LoadTemplate {
    my $action = shift;
    my $cgi = Bugzilla->cgi;
    my $template = Bugzilla->template;

    $vars->{'classifications'} = [Bugzilla::Classification->get_all]
      if ($action eq 'select');
    # There is currently only one section about classifications,
    # so all pages point to it. Let's define it here.
    $vars->{'doc_section'} = 'classifications.html';

    $action =~ /(\w+)/;
    $action = $1;
    print $cgi->header();
    $template->process("admin/classifications/$action.html.tmpl", $vars)
      || ThrowTemplateError($template->error());
    exit(1);
}

#
# Preliminary checks:
#

Bugzilla->login(LOGIN_REQUIRED);

print $cgi->header();

Bugzilla->user->in_group('editclassifications')
  || ThrowUserError("auth_failure", {group  => "editclassifications",
                                     action => "edit",
                                     object => "classifications"});

ThrowUserError("auth_classification_not_enabled") 
    unless Bugzilla->params->{"useclassification"};

#
# often used variables
#
my $action     = trim($cgi->param('action')         || '');
my $class_name = trim($cgi->param('classification') || '');
my $token      = $cgi->param('token');

#
# action='' -> Show nice list of classifications
#
LoadTemplate('select') unless $action;

#
# action='add' -> present form for parameters for new classification
#
# (next action will be 'new')
#

if ($action eq 'add') {
    $vars->{'token'} = issue_session_token('add_classification');
    LoadTemplate($action);
}

#
# action='new' -> add classification entered in the 'action=add' screen
#

if ($action eq 'new') {
    check_token_data($token, 'add_classification');

    my $classification =
      Bugzilla::Classification->create({name        => $class_name,
                                        description => scalar $cgi->param('description'),
                                        sortkey     => scalar $cgi->param('sortkey')});

    delete_token($token);

    $vars->{'message'} = 'classification_created';
    $vars->{'classification'} = $classification;
    $vars->{'classifications'} = [Bugzilla::Classification->get_all];
    $vars->{'token'} = issue_session_token('reclassify_classifications');
    LoadTemplate('reclassify');
}

#
# action='del' -> ask if user really wants to delete
#
# (next action would be 'delete')
#

if ($action eq 'del') {

    my $classification = Bugzilla::Classification->check($class_name);

    if ($classification->id == 1) {
        ThrowUserError("classification_not_deletable");
    }

    if ($classification->product_count()) {
        ThrowUserError("classification_has_products");
    }

    $vars->{'classification'} = $classification;
    $vars->{'token'} = issue_session_token('delete_classification');

    LoadTemplate($action);
}

#
# action='delete' -> really delete the classification
#

if ($action eq 'delete') {
    check_token_data($token, 'delete_classification');

    my $classification = Bugzilla::Classification->check($class_name);
    $classification->remove_from_db;
    delete_token($token);

    $vars->{'message'} = 'classification_deleted';
    $vars->{'classification'} = $classification;
    LoadTemplate('select');
}

#
# action='edit' -> present the edit classifications from
#
# (next action would be 'update')
#

if ($action eq 'edit') {
    my $classification = Bugzilla::Classification->check($class_name);

    $vars->{'classification'} = $classification;
    $vars->{'token'} = issue_session_token('edit_classification');

    LoadTemplate($action);
}

#
# action='update' -> update the classification
#

if ($action eq 'update') {
    check_token_data($token, 'edit_classification');

    my $class_old_name = trim($cgi->param('classificationold') || '');
    my $classification = Bugzilla::Classification->check($class_old_name);

    $classification->set_name($class_name);
    $classification->set_description(scalar $cgi->param('description'));
    $classification->set_sortkey(scalar $cgi->param('sortkey'));

    my $changes = $classification->update;
    delete_token($token);

    $vars->{'message'} = 'classification_updated';
    $vars->{'classification'} = $classification;
    $vars->{'changes'} = $changes;
    LoadTemplate('select');
}

#
# action='reclassify' -> reclassify products for the classification
#

if ($action eq 'reclassify') {
    my $classification = Bugzilla::Classification->check($class_name);
   
    my $sth = $dbh->prepare("UPDATE products SET classification_id = ?
                             WHERE name = ?");

    if (defined $cgi->param('add_products')) {
        check_token_data($token, 'reclassify_classifications');
        if (defined $cgi->param('prodlist')) {
            foreach my $prod ($cgi->param("prodlist")) {
                trick_taint($prod);
                $sth->execute($classification->id, $prod);
            }
        }
        delete_token($token);
    } elsif (defined $cgi->param('remove_products')) {
        check_token_data($token, 'reclassify_classifications');
        if (defined $cgi->param('myprodlist')) {
            foreach my $prod ($cgi->param("myprodlist")) {
                trick_taint($prod);
                $sth->execute(1,$prod);
            }
        }
        delete_token($token);
    }

    $vars->{'classifications'} = [Bugzilla::Classification->get_all];
    $vars->{'classification'} = $classification;
    $vars->{'token'} = issue_session_token('reclassify_classifications');

    LoadTemplate($action);
}

#
# No valid action found
#

ThrowUserError('unknown_action', {action => $action});
