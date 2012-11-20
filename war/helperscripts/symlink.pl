#!/usr/bin/perl
use Cwd 'abs_path';
my $file = $ARGV[0];
$file = abs_path($file);
$file = abs_path(readlink $file) if -l $file;
$file = "$file\.zip"  if !-e $file && -e "$file\.zip";
$file = "$file\.gz"  if !-e $file && -e "$file\.gz";
$file = "$file\.bz2"  if !-e $file && -e "$file\.bz2";
print   "$file\n";