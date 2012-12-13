#!/usr/bin/perl
use File::Basename;

$N=1; 

print getHeader();


while(my $line=<> )
{
	my($sample,$dir) = split(/\s+/,$line);
	chomp $dir;
	$dir =~ /\/(\w+)_(\w+)_(\w+)$/;
	my $flowcell = $1;
	my $lane = $2;
	my $lib = $3;
	
	$localDir = $dir;
	$localDir =~ s/^\/export/\/storage\/hpcc/;
	
	my $file = "ERROR: CANT FIND BAM FILE FOR MERGE!";
	$file = "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam" if -e "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam" || -e "$localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.bam";
	$file = "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" if -e "$dir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" || -e "$localDir/ResultCount_$flowcell\_$lane\_$lib\.hg19_rCRSchrm.fa.mdups.bam" ;
	
	
	
	

	die "$file" if $file =~ /^ERROR/;
	#print STDERR "$lib: merging in $file\n";
	$files{$lib} .= "$file,";
	die "1 to 1 Geneus-TCGA id fail: $samples{$lib} : $lib : $sample\n" if $samples{$lib} && $samples{$lib} ne $sample;
	$samples{$lib} = "$sample";
}

$files{$_} =~ s/\,$// for keys %files;
print getParam($_) for keys %files;

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
