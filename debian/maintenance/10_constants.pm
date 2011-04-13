
our $bz_locations_param_mode = '.PARAMS.IN.ETC.OFF.';

# Debian - This is a wrapper arround the default bz_locations() function. The original function is renamed to bz_locations_nondebian().
sub bz_locations {
	if (@_ and ($_[0] eq '.PARAMS.IN.ETC.ON.' or $_[0] eq '.PARAMS.IN.ETC.OFF.')) {
		$bz_locations_param_mode = $_[0];
		return;
	}
	my $locations = bz_locations_nondebian(@_);
	my $origlibpath = $locations->{'libpath'};

	# support for multi-site installation through X_BUGZILLA_SITE variable to
	# be passed by Apache.
	my $xsite = '';
	if (defined $ENV{X_BUGZILLA_SITE}) {
	    $xsite = "$ENV{X_BUGZILLA_SITE}";
	    # untaint (make sure it has no '/' and is overall something sane)
	    if ($xsite =~ m/^(\w[\w\-.]*)$/) {
		$xsite ="$1";
	    } else {
		die "invalid X_BUGZILLA_SITE: $xsite";
	    }
	}
	# Constant default paths.
	my %overwritten_locations = (
		'libpath' => "/usr/share/perl5",
		'cgi_path' => "/usr/share/bugzilla4/web",
		'localconfig' => "/etc/bugzilla4/localconfig",
		'debian_paramsdir' => "/etc/bugzilla4",
		'skinsdir' => "/usr/share/bugzilla4/web/skins",
		# It's important to use cgi_path for webdotdir in order to get
		# substitution in showdependencygraph.cgi working. On the filesystem
		# /var/lib/bugzilla4/data/webdot is the right directory which
		# symlinked in /usr/share/bugzilla4/web as data(/webdot).
		'webdotdir' => "/usr/share/bugzilla4/web/data/webdot",
		# The `project` entry is only a simplification to skip this entry for substitution.
		'project' => $locations->{'project'},
		);

	# For providing a simple way to install several virtual hosts of the same
	# package, we use also here an Apache environment variable for specifing
	# the webpath. This will give a nice way to customize several VirtualHosts.
	if (defined $ENV{'X_BUGZILLA_WEBPATH'}) {
		$overwritten_locations{'debian_webpath'} = $ENV{'X_BUGZILLA_WEBPATH'};
	}
	else {
		$overwritten_locations{'debian_webpath'} = '/bugzilla4/';
	}

	# Apply our changes.
	for my $localkey (keys %overwritten_locations) {
		$locations->{$localkey} = $overwritten_locations{$localkey};
	}
	my $varlib = "/var/lib/bugzilla4";

	# Transform all entris to new `libpath` directory.
	for my $localkey (keys %{$locations}) {
		next if exists $overwritten_locations{$localkey};
		$locations->{$localkey} =~ s/^$origlibpath\//$varlib\//;
	}

	if ($locations->{'project'}) {
		$locations->{'localconfig'} .= $locations->{'project'};
		$locations->{'datadir'} .= "/" . $locations->{'project'};
	}
	# If we have a $xsite (the Debian way), let's manage the conf paths correctly.
	elsif ($xsite) {
		$locations->{'debian_paramsdir'} .= "/sites/${xsite}";
		$locations->{'localconfig'} = $locations->{'debian_paramsdir'} . "/localconfig";
		for my $localkey (keys %{$locations}) {
			next if exists $overwritten_locations{$localkey};
			$locations->{$localkey} =~ s/^$varlib\//$varlib\/$xsite\//;
		}
		if (! -d $locations->{'templatedir'}) {
			$locations->{'templatedir'} = $varlib . "/template";
		}
	}
	# We like an per project graphs dir.
	$locations->{'graphsdir'} = $locations->{'datadir'} . "/graphs";

	# Workarround to change param file to /etc.
	if ($bz_locations_param_mode eq '.PARAMS.IN.ETC.ON.') {
		$locations->{'datadir'} = $locations->{'debian_paramsdir'};
	}
	return $locations;
}

1;
