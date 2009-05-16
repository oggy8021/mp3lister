#!/usr/bin/perl

# perl dir_fn.pl [Directory] [mode]
# mode as
# -c ... check
# -r ... run [default]


use File::Basename;
use Jcode;

#----------------------

$arg_dir = $ARGV[0];
$mode = $ARGV[1];

&start($arg_dir);

sub start
{
	local($dir) = $_[0];

	$dir =~ s/\s/\\ /g;
	$dir = ".";

	opendir(DIR, $dir) || die("Can not Open Directory : $dir");
	my @dir = readdir(DIR);
	closedir(DIR);

	foreach (@dir)
	{
#		printf "$dir\n";		##DEBUG
		next if (($_ eq '.') or ($_ eq '..'));
		next if ($_ =~ m/^(_Single|_single|Single)$/);
		if (-d $_) {
#			print "$_ is Dir\n";		##DEBUG
			&sub_dir($_);
		} else {
#			print "$_ is File\n";		##DEBUG
			&sub_file($_);
		}
	}
}

sub sub_dir
{
	local($dir) = $_[0];
	
	chdir $dir || die("Can not Change Directory : $dir");
	print "$dir に入ります\n";
	&start($dir);
	print "$dir を出ます\n";
	chdir "..";
}

sub sub_file
{
	local($file) = $_[0];
	
#	print "$fileです \n";		##DEBUG
	$fname = basename($file);
	$cname = $fname;
#	$bname = basename($file, ".mp3");

	#rename
	$cname =~ s/\(/[/g;
	$cname =~ s/\)/]/g;
	$cname =~ s/'//g;
	$cname =~ s/\s/_/g;
	$sjname = &esc_filename($cname);

	if ($mode eq "-c") {
		print "Convert Image ===> $sjname\n";
	} elsif ($mode eq "-r" or $mode eq "") {
		print "Converted ... $sjname ...";
		rename($fname, $cname);
		if ($?) {
			print("NG\n");
		} else {
			print("OK\n");
		}
	} else {
		die "Miss mode setting error\n";
	}

}

sub esc_filename
{
	local($filename) = $_[0];

#	my $mcode = 'sjis'; ## sjis, euc, jis
	my $mcode = 'euc';
	$filename = Jcode::convert($filename, $mcode);
	return $filename;
}

