#!/bin/sh
bzr co bzr://bzr.mozilla.org/bugzilla/4.2 bugzilla42
tar -zcvf bugzilla_4.2.0.orig.tar.gz bugzilla42
rm -rf bugzilla42
