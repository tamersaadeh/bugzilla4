# Makefile written for the Debian package.
# Based on the Remi Perrot's one, done for 
# the 2.18 release.

# Make sure it's the same in
# + debian/rules
# + debian/Makefile
# + maintenance/checksetup_debian.sh
# + debian/bugzilla3.{pre,post}{inst,rm}
export BUGZILLA_PKGDIR := $(CURDIR)/debian/bugzilla3
export BUGZILLA_ETCDIR := $(BUGZILLA_PKGDIR)/etc/bugzilla3
export BUGZILLA_VARDIR := $(BUGZILLA_PKGDIR)/var/lib/bugzilla3
export BUGZILLA_DATADIR := $(BUGZILLA_VARDIR)/data
export BUGZILLA_SHAREDIR := $(BUGZILLA_PKGDIR)/usr/share/bugzilla3
export BUGZILLA_WEBDIR := $(BUGZILLA_PKGDIR)/usr/share/bugzilla3/web
export BUGZILLA_CONTRIBDIR := $(BUGZILLA_SHAREDIR)/contrib
export BUGZILLA_TEMPLATEDIR := $(BUGZILLA_VARDIR)/template
export BUGZILLA_COMPILEDTEMPLATEDIR := $(BUGZILLA_DATADIR)/template
export BUGZILLA_EXTENSIONSDIR := $(BUGZILLA_VARDIR)/extensions

# Destination paths
# For a better maintenance, we'll create by hand each
# bugzilla's sub directories.
BUGZILLA_PERLDIR= $(BUGZILLA_PKGDIR)/usr/share/perl5
BUGZILLA_DOCDIR = $(BUGZILLA_PKGDIR)/usr/share/doc/bugzilla3
BUGZILLA_WWW	= $(BUGZILLA_SHAREDIR)/web
BUGZILLA_CGIDIR = $(BUGZILLA_WWW)
BUGZILLA_CONTRIB= $(BUGZILLA_SHAREDIR)/contrib

PKGVER := $(shell dpkg-parsechangelog |grep Version: |sed -e 's,Version: \([^-]\+\).*,\1,g')
ORIGTARGZ := bugzilla_$(PKGVER).orig.tar.gz

# Source paths
cgi_files	= *.cgi
lib_files	= *.pm 
pl_files	= runtests.pl 
lib_dir		= Bugzilla
static_files	= *.dtd *.txt 

# Where to find the sources.
BUGZILLA_SRCDIR = bugzilla-srcdir

INSTALL = /usr/bin/install

extractsrc:	$(BUGZILLA_SRCDIR)/checksetup.pl
$(BUGZILLA_SRCDIR)/checksetup.pl:
	$(CURDIR)/debian/create-bugzilla-srcdir


install: install_static_files install_images install_js install_lib_files \
	 install_cgi install_template install_skins install_contrib install_extensions


install_contrib:	extractsrc
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_CONTRIB)
	cp -av $(BUGZILLA_SRCDIR)/contrib/* $(BUGZILLA_CONTRIB)
	grep -rl "^#\!.*/bin/.*" $(BUGZILLA_CONTRIB) | xargs chmod a+x


install_extensions:	extractsrc
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_EXTENSIONSDIR)
	: # Install extensions as documentation until we have a real extensions support
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_DOCDIR)
	cd $(BUGZILLA_SRCDIR) && for this_dir in `find extensions -type d` ; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_DOCDIR)/$$this_dir ;\
	done
	cd $(BUGZILLA_SRCDIR) && for this_file in `find extensions -type f -not -name "create.pl"` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_DOCDIR)/`dirname $$this_file` ;\
	done
	: # Create an archive for these extensions
	tar -C $(BUGZILLA_DOCDIR) -czf $(BUGZILLA_DOCDIR)/extensions.tgz extensions
	rm -rf $(BUGZILLA_DOCDIR)/extensions


install_skins:	extractsrc
	cd $(BUGZILLA_SRCDIR) && for this_dir in `find skins -type d` ; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_WWW)/$$this_dir ;\
	done
	cd $(BUGZILLA_SRCDIR) && for this_file in `find skins -type f` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_WWW)/`dirname $$this_file` ;\
	done


install_template:	extractsrc
	cd $(BUGZILLA_SRCDIR) && for this_dir in `find template -type d` ; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_VARDIR)/$$this_dir ;\
	done
	cd $(BUGZILLA_SRCDIR) && for this_file in `find template -type f` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_VARDIR)/`dirname $$this_file` ;\
	done


install_static_files:	extractsrc
	cd $(BUGZILLA_SRCDIR) && for this_dir in duplicates webdot; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_DATADIR)/$$this_dir ;\
	done
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_WWW)
	cd $(BUGZILLA_SRCDIR) && $(INSTALL) -m 0644 -o root -g root $(static_files) $(BUGZILLA_WWW)

install_images:
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_WWW)/images
	cd $(BUGZILLA_SRCDIR) && for this_file in `find images -type f` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_WWW)/`dirname $$this_file` ;\
	done

install_js:
	cd $(BUGZILLA_SRCDIR) && for this_dir in `find js -type d` ; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_WWW)/$$this_dir ;\
	done
	cd $(BUGZILLA_SRCDIR) && for this_file in `find js -type f` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_WWW)/`dirname $$this_file` ;\
	done


install_lib_files:	extractsrc
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_SHAREDIR)
	cd $(BUGZILLA_SRCDIR) && $(INSTALL) -m 0644 -o root -g root $(lib_files) $(BUGZILLA_SHAREDIR)
	cd $(BUGZILLA_SRCDIR) && $(INSTALL) -m 0755 -o root -g root $(pl_files) $(BUGZILLA_SHAREDIR)
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_SHAREDIR)/lib
	cd $(BUGZILLA_SRCDIR) && $(INSTALL) -m 0755 -o root -g root *.pl $(BUGZILLA_SHAREDIR)/lib
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_PERLDIR)
	cd $(BUGZILLA_SRCDIR) && for this_dir in `find $(lib_dir) -type d` ; do \
		$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_PERLDIR)/$$this_dir ;\
	done
	cd $(BUGZILLA_SRCDIR) && for this_file in `find $(lib_dir) -type f` ; do \
		$(INSTALL) -m 0644 -o root -g root $$this_file $(BUGZILLA_PERLDIR)/`dirname $$this_file` ;\
	done


install_cgi:	extractsrc
	$(INSTALL) -d -m 0755 -o root -g root $(BUGZILLA_CGIDIR)
	cd $(BUGZILLA_SRCDIR) && $(INSTALL) -m 0755 -o root -g root $(cgi_files) $(BUGZILLA_CGIDIR)


clean:
	rm -rf $(BUGZILLA_SRCDIR)


orig:	../$(ORIGTARGZ)
../$(ORIGTARGZ):
	tar -czf ../$(ORIGTARGZ) *.tar*

.PHONY: orig clean extractsrc install install_images install_js install_static_files install_lib_files install_cgi install_template install_skins install_contrib install_extensions
