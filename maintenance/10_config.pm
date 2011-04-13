
sub read_param_file {
	bz_locations('.PARAMS.IN.ETC.ON.');
	my $params = read_param_file_nondebian(@_);
	bz_locations('.PARAMS.IN.ETC.OFF.');
	return $params;
}

sub write_params {
	bz_locations('.PARAMS.IN.ETC.ON.');
	write_params_nondebian(@_);
	bz_locations('.PARAMS.IN.ETC.OFF.');
}

1;
