#!/usr/bin/perl

# perl dir_fn.pl [Directory]


use File::Basename;

#----------------------

$arg_dir = $ARGV[0];

&start($arg_dir);

sub start
{
	local($dir) = $_[0];

	$dir =~ s/\s/\\ /g;

	opendir(DIR, $dir) || die("Can not Open Directory : $dir");
	my @dir = readdir(DIR);
	foreach (@dir) {
		print "$_\n";
	}
	closedir(DIR);
}

