#!/bin/sh
# -*- sh -*-
# Copyright (C) 2009  Raphael Bossek <bossekr@debian.org>
# This is not a joke! It's a shell script not Perl.
# This file is a wrapper around the original checksetup.pl Perl script to apply Debian's modifications.

set -e

# Make sure it's the same in
# + debian/rules
# + maintenance/checksetup_debian.sh
# + debian/bugzilla3.{pre,post}{inst,rm}
std_exports()
{
    export BUGZILLA_ETCDIR="/etc/bugzilla3"
    export BUGZILLA_VARDIR="/var/lib/bugzilla3"
    export BUGZILLA_DATADIR="$BUGZILLA_VARDIR/data"
    export BUGZILLA_SHAREDIR="/usr/share/bugzilla3"
    export BUGZILLA_WEBDIR="$BUGZILLA_SHAREDIR/web"
    export BUGZILLA_CONTRIBDIR="$BUGZILLA_SHAREDIR/contrib"
    export BUGZILLA_TEMPLATEDIR="$BUGZILLA_VARDIR/template"
    export BUGZILLA_COMPILEDTEMPLATEDIR="$BUGZILLA_DATADIR/template"
    export BUGZILLA_EXTENSIONSDIR="$BUGZILLA_VARDIR/extensions"
}

cleanup()
{
    rm -f "$tmplog" "$answerf"
}

checksetup()
{
    # /usr/share/bugzilla3/lib/checksetup_nondebian.pl exit with error code 9
    # if the /etc/bugzilla3/localconfig variables where updated. In this case
    # we restart checksetup_nondebian.pl to apply the changes.
    errorcode=9
    while [ "$errorcode" = "9" ]; do
        echo "Run X_BUGZILLA_SITE=\"$X_BUGZILLA_SITE\" su www-data -p -c perl /usr/share/bugzilla3/lib/checksetup_nondebian.pl $* >>$tmplog"
        su www-data -p -c "perl /usr/share/bugzilla3/lib/checksetup_nondebian.pl $*" >>"$tmplog" 2>&1 \
            && errorcode=0 \
            || errorcode=$?
    done
    cat "$tmplog" | \
        sed -e 's,/usr/bin/perl .*install-module\.pl "Template::Plugin::GD::Image".*,apt-get install libtemplate-plugin-gd-perl,g' \
            -e 's,/usr/bin/perl install-module.pl HTML::Scrubber.*,apt-get install libhtml-scrubber-perl,g' \
            -e 's,/usr/bin/perl install-module.pl mod_perl2.*,apt-get install libapache2-mod-perl2,g' \
            -e 's,/usr/bin/perl install-module.pl MIME::Parser.*,apt-get install libmime-tools-perl,g' \
            -e 's,/usr/bin/perl install-module.pl CGI.*,apt-get install libcgi-pm-perl,g' \
            -e 's,/usr/bin/perl install-module.pl SOAP::Lite.*,apt-get install libsoap-lite-perl,g' \
            -e 's,/usr/bin/perl install-module.pl Chart::Lines.*,apt-get install libchart-perl,g' \
            -e 's,/usr/bin/perl install-module.pl GD.*,apt-get install libgd-gd2-perl,g' \
            -e 's,/usr/bin/perl install-module.pl GD::Text.*,apt-get install libgd-text-perl,g' \
            -e 's,/usr/bin/perl install-module.pl GD::Graph.*,apt-get install libgd-graph-perl,g' \
            -e 's,/usr/bin/perl install-module.pl XML::Twig.*,apt-get install libxml-twig-perl,g' \
            -e 's,/usr/bin/perl install-module.pl LWP::UserAgent.*,apt-get install libwww-perl,g' \
            -e 's,/usr/bin/perl install-module.pl Image::Magic.*,apt-get install perlmagick,g' \
            -e 's,/usr/bin/perl install-module.pl Net::LDAP.*,apt-get install libnet-ldap-perl,g' \
            -e 's,/usr/bin/perl install-module.pl Authen::SASL.*,apt-get install libauthen-sasl-perl,g' \
            -e 's,/usr/bin/perl install-module.pl Authen::Radius.*,apt-get install libauthen-radius-perl,g' \
            -e 's,/usr/bin/perl install-module.pl JSON::RPC.*,apt-get install libjson-rpc-perl,g' \
            -e 's,/usr/bin/perl install-module.pl Test::Taint.*,apt-get install libtest-taint-perl,g' \
            -e 's,/usr/bin/perl install-module.pl TheSchwartz.*,apt-get install libtheschwartz-perl,g' \
            -e 's,/usr/bin/perl install-module.pl HTML::Parser.*,apt-get install libhtml-parser-perl,g' | \
        sed -e 's,\: /usr/bin/perl install-module.pl ,\: dh-make-perl --install --cpan ,g' \
            -e 's,http://cyberelk.net/tim/patchutils/,apt-get install patchutils,g' \
            -e 's,/usr/bin/perl install-module.pl --all,view /usr/share/doc/bugzilla3/README.Debian*,g'
     return $errorcode
}

trap cleanup QUIT EXIT
umask 0027
std_exports

tmplog=`mktemp -t checksetup.log.XXXXXXXXXX`
errorcode=0
# The BUGZILLA_CHECKSETUP_FAILED variable is empty until an error occurs.
export BUGZILLA_CHECKSETUP_FAILED=""

debiandir="$BUGZILLA_SHAREDIR/debian/"
d="$BUGZILLA_ETCDIR/pre-checksetup.d"
echo "run-parts --exit-on-error --lsbsysinit $d"
if [ -d "$d" ]; then
    run-parts --verbose --exit-on-error --lsbsysinit "$d" \
    || errorcode=$?
fi

# Create a new answerfile for checksetup.pl.
answerf=`mktemp -p $BUGZILLA_ETCDIR -t answerfile.XXXXXXXXXX`
chgrp www-data "$answerf"
chmod 0640 "$answerf"
# Reuse the /etc/bugzilla3/localconfig variables for some of the questions.
cat "$BUGZILLA_ETCDIR/localconfig" >>"$answerf"
echo "\$answer{'db_host'} = \$db_host;" >>"$answerf"
echo "\$answer{'db_port'} = \$db_port;" >>"$answerf"
echo "\$answer{'db_name'} = \$db_name;" >>"$answerf"
echo "\$answer{'db_user'} = \$db_user;" >>"$answerf"
echo "\$answer{'db_pass'} = q[\$db_pass = \$db_pass;];" >>"$answerf"
echo "\$answer{'NO_PAUSE'} = 1;" >>"$answerf"
echo "\$answer{'ADMIN_OK'} = 'Y';" >>"$answerf"
# Reuse the Debconf answers.
cat "$BUGZILLA_DATADIR/answerfile" >>"$answerf"

if [ "$errorcode" = "0" ]; then
    checksetup "$answerf" $@ \
    || errorcode=$?

    [ "$errorcode" = "0" ] \
    || export BUGZILLA_CHECKSETUP_FAILED="$errorcode"
fi

# update all the bugzilla sites
if [ "$errorcode" = "0" -a -d /etc/bugzilla3/sites ]; then
    for site in `cd /etc/bugzilla3/sites/ && ls -1`; do 
        X_BUGZILLA_SITE="$site" checksetup $@ \
        || errorcode=$?

        if [ "$errorcode" != "0" ]; then
            export BUGZILLA_CHECKSETUP_FAILED="$errorcode"
            break
        fi
    done
fi

d="$BUGZILLA_ETCDIR/post-checksetup.d"
echo "run-parts --exit-on-error --lsbsysinit $d"
if [ -d "$d" ]; then
    run-parts --verbose --exit-on-error --lsbsysinit "$d" \
    || errorcode=$?
fi

[ "$BUGZILLA_CHECKSETUP_FAILED" ] \
&& errorcode="$BUGZILLA_CHECKSETUP_FAILED"

exit $errorcode

# vim:ts=4 et sw=4
