#! /bin/sh

set -e

echo "> $0 $*"
dir="$1"

tmpf=`tempfile`
trap "rm $tmpf" EXIT QUIT

f="$dir/checksetup.pl"
sed -e 's,^fix_all_file_permissions,#fix_all_file_permissions,g' "$f" >"$tmpf"
diff -u "$f" "$tmpf" || true
cat "$tmpf" >"$f"
