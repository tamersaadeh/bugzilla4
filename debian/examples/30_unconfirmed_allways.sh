#!/bin/sh
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
# The Initial Developer of the Original Code is Netscape Communications
# Corporation. Portions created by Netscape are
# Copyright (C) 2000 Netscape Communications Corporation.  All
# Rights Reserved.
# 
# Contributor(s): Raphael Bossek <bossekr@debian.org>
#

# Change the code to set UNCONFIRMED status as default recarding of the configuration.
# Setup:
# ln -s /usr/share/doc/bugzilla4/examples/30_unconfirmed_allways.sh /etc/bugzilla4/pre-checksetup.d/

set -e

tmpf=`tempfile`
trap "rm -f $tmpf" EXIT QUIT

f="/usr/share/bugzilla4/web/enter_bug.cgi"
if grep -q '^unless ($has_editbugs || $has_canconfirm) {' "$f" 2>/dev/null; then
	sed -e 's,^unless ($has_editbugs || $has_canconfirm) {,if (1) {,g' "$f" >"$tmpf"
	cat "$tmpf" >"$f"
fi

exit 0
