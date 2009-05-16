#!/usr/bin/perl

# perl dir_fn.pl [Directory]


use File::Basename;
use File::Find;

#----------------------

@search_dirs = $ARGV[0];

find(\&mp3files, @search_dirs);

sub mp3files
{
	next if (($_ eq '.') or ($_ eq '..'));
	next if ($_ =~ m/^(_Single|_single|Single)$/);

	$fname =  $File::Find::name;
	$cname = $fname;

	$cname =~ s/\(/[/g;
	$cname =~ s/\)/]/g;
	$cname =~ s/'//g;
	$cname =~ s/\s/_/g;
#	print "$fname => $cname\n";		##DEBUG
	print "===> $cname\n";		##DEBUG
#	rename($fname, $cname) || die("Can not change File Name");
}
