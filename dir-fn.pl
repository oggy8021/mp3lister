#!/usr/bin/perl

# perl dir_fn.pl [Directory] [mode]
# mode as
# -c ... check
# -r ... run [default]
# -l ... list

# Filename [99-xxxxxx.mp3]
$hidden_mode = $ARGV[2];
if ($hidden_mode eq '') {
	$hidden_mode = 1;
}
# print "hidden_mode = $hidden_mode\n";
# exit;

#Windows Filename
$wmark = << 'EOF';
ー!#$％&’（）＝＾｛｝＿、，−ⅠⅡⅢ
EOF
$smark = << 'EOF';
-!#$%＆\'()=^{}_,,-123
EOF

#----------------------

use File::Basename;
use Cwd;
use Jcode;

$arg_dir = $ARGV[0];
$mode = $ARGV[1];

#デフォルト：チェックモード（怖いので）
$mode = "-c" if ($mode eq "");

#「.」以外であたえられるディレクトリ名対応
if (-d $arg_dir) {
	chdir $arg_dir || die("Can not Change Directory : $arg_dir");
	$arg_dir = Cwd::getcwd();

	#プレイリストのルート
	$tree = $arg_dir . "/";
}

#初回呼び出し
&start($arg_dir);

sub start
{
	local($dir) = $_[0];

	#先に空白を含むファイル名であったとき、\を付けることでアクセスする
	$dir =~ s/\s/\\ /g if ($mode ne '-l');

	opendir(DIR, $dir) || die("Can not Open Directory : $dir");
	my @dir = readdir(DIR);
	closedir(DIR);

	foreach (@dir)
	{
		#本当は、先に除去の上ソートしたい（が、うまく動かないので）
		next if (($_ eq '.') or ($_ eq '..'));

		#シングルは走査対象にしない
		next if ($_ =~ m/^(_Single|_single|Single|except|除外|11_only_name).*$/);

		#ディレクトリか、ファイルか
		if (-d $_) {
			&sub_dir($_);
		} else {
			&sub_file($_);
		}
	}
}


sub sub_dir
{
	local($dir) = $_[0];
	
	#引数にて与えられたディレクトリに入る
	chdir $dir || die("Can not Change Directory : $dir");
	print " --- $dir に入ります\n" if ($mode ne "-l");

	#現ファイルパスを記憶
	$tree = Cwd::getcwd()  . "/";

	#入ったディレクトリをカレントとして再帰呼び出し
	$dir = ".";
	&start($dir);

	#カレントディレクトリをフルパスに戻す
	$dir = Cwd::getcwd();

	#出る
	print " --- $dir を出ます\n" if ($mode ne "-l");
	chdir "..";

	#操作していたディレクトリ名に不都合があれば変換する
	$conv_dir = $dir;
	$conv_dir = &convert_name($conv_dir);

	if ($mode eq "-c") {
		print "Convert Dir   ==> $conv_dir\n";
	} elsif ($mode eq "-r") {
		print "Converted Dir ... $conv_dir ...";
		rename($dir, $conv_dir);
		if ($?) {
			print("NG\n");
		} else {
			print("OK\n");
		}
	}

	#一応パスを居るディレクトリに合わせておく（いらんかも）
	$tree = Cwd::getcwd()  . "/";
}


sub sub_file
{
	local($file) = $_[0];
	
	$fname = basename($file);

#zip以外および、01-hogehoge.mp3といった形式にあるファイルのみを
	return if ($hidden_mode and $fname !~ m/^([0-9][0-9])-(.*)(\.mp3|\.MP3)$/);
	return if ($fname =~ m/^(.*)zip(.*)(\.mp3|\.MP3)$/);
	return if ($fname !~ m/^(.*)(\.mp3|\.MP3)$/);
#	return if ($hidden_mode and $fname =~ m/^(.*)zip(.*)(\.mp3)$/);

#一応、eucへコンバート
	$tmp_name = Jcode::convert($fname, 'euc');
	if ($tmp_name eq "") {
		$tmp_name = $fname;		##たまに転ける？
	}
#	print "prename : $tmp_name\n";		##DEBUG
	$tmp_name = &convert_name($tmp_name);

#$modeに応じて動作
	if ($mode eq "-c") {
		print "Convert File  ==> $tmp_name\n";
	} elsif ($mode eq "-r") {
		print "Converted ... $tmp_name ...";
		rename($fname, $tmp_name);
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

sub convert_name
{
	my($name) = $_[0];

	#大文字記号系を変換
	$name = Jcode->new($name)->tr($wmark, $smark)->euc;

	#UNIX系、mpg123が"(", ")"を嫌うので、他
	$name =~ s/\(/[/g;
	$name =~ s/\)/]/g;
	$name =~ s/\'//g;
	$name =~ s/\s/_/g;

	return $name;
}
