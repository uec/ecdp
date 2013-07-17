#!/usr/bin/perl
use File::Basename;
use POSIX qw( strftime );

$N=1; 
my $output = getHeader();
my $libCount;



while(my $line=<> )
{
	
	my($sample,$dir) = split(/\s+/,$line);
	chomp $dir;
	$dir =~ /\/(\w+)_(\w+)_(\w+)$/;
	my $flowcell = $1;
	my $lane = $2;
	my $lib = $3;
	#print STDERR "1:$flowcell 2:$lane 3:$lib dir:$dir\n";
	next if !$lib;
	$libCount = $lib if !$libCount; 
	print "ERROR, you cannot merge differing samples (downstream tools such as GATK/BISSNP will not work correctly)" if $lib ne $libCount;
	die "ERROR, you cannot merge differing samples (downstream tools such as GATK/BISSNP will not work correctly)" if $lib ne $libCount;
	
	$localDir = $dir;
	$localDir =~ s/^\/export/\/storage\/hpcc/;
	
	#locate the bams
	my $file = "ERROR: CANT FIND BAM FILE FOR MERGE! tried:\n$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam $localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam\n$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam\n$localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam";
	$file = "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam" if -e "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam" || -e "$localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam";
	$file = "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" if -e "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" || -e "$localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" ;
	die "$file" if $file =~ /^ERROR/;
	
	#convert back to hpcc fs paths and calc symlinks
	$file =~ s/\/storage\/hpcc/\/export/;
	my $fileLinkPath = $file;
	$fileLinkPath =~ s/^.+?flowcells/\.\.\/\.\.\/flowcells/;
	push @symlinks, $fileLinkPath;
	#$output .= "#HPCC symlink to $fileLinkPath\n";
	
	#print STDERR "$lib: merging in $file\n";
	$files{$lib} .= "$file,";
	die "1 to 1 Geneus-TCGA id fail: $samples{$lib} : $lib : $sample\n" if $samples{$lib} && $samples{$lib} ne $sample;
	$samples{$lib} = "$sample";
}


$files{$_} =~ s/\,$// for keys %files;
$output .= getParam($_) for keys %files;

print $output;
exit if scalar(keys %files < 1);

#create the workflow run dir

my $yymmdd = strftime("%Y-%m-%d_%H%M", localtime());
my $mergeDir = "$yymmdd\_merge_" . join("_", keys %samples);
mkdir "/storage_rw/merges/$mergeDir";
chdir  "/storage_rw/merges/$mergeDir";
system("rm /storage_rw/merges/$mergeDir/*");
system("ln -s $_") for @symlinks;
open(OUT, ">workFlowParams.txt");
print OUT $output;
close OUT;
print "#WORKFLOW CREATED AT HPCC /export/uec-gs1/laird/shared/production/ga/merges/$mergeDir\n";
print "#IT HAS NOT BEEN STARTED IMMEDIATELY, BUT WILL BE SUBMITTED ACCORDING TO SCHEDULE!\n";
print "#TO CANCEL, DELETE  /export/uec-gs1/laird/shared/production/ga/merges/$mergeDir SOON\n";

&notify_mail("NEW MERGING WORKFLOW CREATED AT HPCC /export/uec-gs1/laird/shared/production/ga/merges/$mergeDir\n",$output);
exit;

##################
sub getParam
{
	my $lib = shift @_; 
	my $param = "#Sample: $samples{$lib}\nSample.$N.SampleID = $lib\nSample.$N.Lane = 1\nSample.$N.Input = $files{$lib}\nSample.$N.Workflow = bismerge\nSample.$N.Reference = /home/uec-00/shared/production/genomes/hg19_rCRSchrm/hg19_rCRSchrm.fa\n\n";
	$N++;
	return $param;
}

sub getHeader
{
	return "ClusterSize = 1\nqueue = laird\nFlowCellName = MERGING\nMinMismatches = 2\nMaqPileupQ = 30\nreferenceLane = 1\nrandomSubset = 300000\n\n";

}

sub notify_mail
{
	my ($subject,$body) = @_;
	open(MAIL, "|/usr/sbin/sendmail -t");
 
	## Mail Header
	print MAIL "To: ramjan\@usc.edu\n";
	print MAIL "From: admin\@ECDP\n";
	print MAIL "Subject: $subject\n\n";
	## Mail Body
	print MAIL "$body\n";
 	close(MAIL);
}
