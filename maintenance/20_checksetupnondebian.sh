#! /bin/sh

set -e

echo "> $0 $*"
dir="$1"

tmpf=`tempfile`
trap "rm $tmpf" EXIT QUIT

if ! grep -q "checksetup_nondebian\.pl" debian/rules -a ! grep -q "checksetup_nondebian\.pl" debian/Makefile; then
	echo >&2 "$0: This script is obsolate becaseu checksetup_nondebian.pl is not supported. Please modify the check or remove this script."
	exit 1
fi

f="$dir/Bugzilla.pm"
# We have renamed checksetup.pl script and need to modify the SHUTODWNHTML_EXEMPT in Bugzilla.pm too!
grep -q "[[:space:]]SHUTDOWNHTML_EXEMPT[[:space:]]" "$f"
sed -e 's,checksetup\.pl,checksetup_nondebian.pl,g' $f >$tmpf
diff -u "$f" "$tmpf" || true
cat "$tmpf" >"$f"
