#!/usr/bin/perl

# perl dir_fn.pl [Directory] [mode]
# mode as
# -c ... check
# -r ... run [default]

# Filename [99-xxxxxx.mp3]
$hidden_mode = 1;

#Windows Filename
$wmark = << "EOF";
!#$％＆’（）＝ー＾｛｝＿
EOF
$smark = << "EOF";
!#$%&\'()=-^{}_
EOF

#----------------------

use File::Basename;
use Jcode;

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
	
	$fname = basename($file);
	$cname = $fname;
#	$bname = basename($file, ".mp3");

#filename starting "99-"
	return if ($hidden_mode and $fname !~ m/^([0-9][0-9])-(.*)(mp3)$/);

#Convert
	$cname =~ s/\(/[/g;
	$cname =~ s/\)/]/g;
	$cname =~ s/'//g;
	$cname =~ s/\s/_/g;
	$cname = Jcode->new($cname,"euc")->tr($wmark, $smark)->sjis;
	$euc_name = &esc_filename($cname);

#mode_check ... rename
	if ($mode eq "-c") {
		print "Convert Image ===> $euc_name\n";
	} elsif ($mode eq "-r" or $mode eq "") {
		print "Converted ... $euc_name ...";
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

