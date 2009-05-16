#!/usr/bin/perl

# perl dir_fn.pl [Directory] [mode]
# mode as
# -c ... check
# -r ... run [default]
# -l ... list

# Filename [99-xxxxxx.mp3]
$hidden_mode = 1;

#Windows Filename
$wmark = << 'EOF';
!#$％＆’（）＝ー＾｛｝＿
EOF
$smark = << 'EOF';
!#$%&\'()=-^{}_
EOF

#----------------------

use File::Basename;
use Jcode;
use Encode;
use Encode::Guess;
#binmode STDOUT,":encoding(euc-jp)";

$arg_dir = $ARGV[0];
$mode = $ARGV[1];
$mode = "-r" if ($mode eq "");

$tree = "./";

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
	print " --- $dir に入ります\n" if ($mode ne "-l");
#	print "$dir に入ります\n";	##DEBUG
	$tree = $tree . $_ . "\/"; 
	&start($dir);
	chdir "..";
	print " --- $dir を出ます\n" if ($mode ne "-l");
#	print "$dir を出ます\n";	##DEBUG
	$tree = substr($tree, 0, rindex($tree, $dir));
}

sub sub_file
{
	local($file) = $_[0];
	
	$fname = basename($file);
	Encode::Guess->set_suspects( qw/ utf8 euc-jp shiftjis cp932 / );
	$aft = guess_encoding($file);
	if (! ref($aft)) {
		print  "Can't guess: \"$aft\"\n";
	} else {
		print  "encoding is ", $aft->name, "\n";
	}

	$aft = guess_encoding($fname);
	if (! ref($aft)) {
		print  "Can't guess: \"$aft\"\n";
	} else {
		print  "encoding is ", $aft->name, "\n";
	}

#filename starting "99-"
	return if ($hidden_mode and $fname !~ m/^([0-9][0-9])-(.*)(mp3)$/);

#Convert
	$tmp_name = Jcode::convert($fname, 'euc');
	if ($tmp_name eq "") {
		$tmp_name = $fname;
	} else {
		$tmp_name =~ s/\(/[/g;
		$tmp_name =~ s/\)/]/g;
		$tmp_name =~ s/\'//g;
		$tmp_name =~ s/\s/_/g;
		$sj_name = Jcode::convert($tmp_cname, 'sjis');
	}

#mode_check ... rename
	if ($mode eq "-c") {
#		print "Convert Image ===> $tmp_name\n";
		if (! ref($aft)) {
			print "\tConvert Image ===> $tmp_name\n";
		} else {
			print "Convert Image ===> $tmp_name\n";
		}
	} elsif ($mode eq "-r") {
		print "Converted ... $euc_name ...";
		rename($fname, $sj_name);
		if ($?) {
			print("NG\n");
		} else {
			print("OK\n");
		}
	} elsif ($mode eq "-l") {
		print $tree . $fname . "\n";
	} else {
		die "Miss mode setting error\n";
	}

}
