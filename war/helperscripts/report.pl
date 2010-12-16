#!/usr/bin/perl
use File::Basename;
use DB_File;
use XML::Simple;

$flowcell = $ARGV[0];
$doQC = 1 if $ARGV[1] =~ /qc/i;
$doTDF = 1 if $ARGV[1] =~ /tdf/i;

#caching
tie %findCache, "DB_File", "/tmp/genFileCache", O_RDWR|O_CREAT, 0666, $DB_HASH;
$cache_expire = 86400;

if(!$findCache{$flowcell} || !$findCache{$flowcell . "WriteTime"} || (time() - $findCache{$flowcell . "WriteTime"} > $cache_expire))
{
	$findCache{$flowcell} = `/usr/bin/locate -d /storage/index/mlocate.db $flowcell | /bin/grep -v Thumbnail_Images | /bin/grep -v .cif | /bin/grep -v .hpc-pbs.usc.edu`;
	$findCache{$flowcell . "WriteTime"} = time();	
}

@allFiles = split(/\n/,$findCache{$flowcell});

#@allFiles = split(/\n/,`/usr/bin/locate -d /storage/index/mlocate.db $flowcell | /bin/grep -v Thumbnail_Images | /bin/grep -v .cif | /bin/grep -v .hpc-pbs.usc.edu`);

#filter unwanted things
@allFiles = grep {
					!m/aligntest/ &&
					!m/Frame\.htm/ 
					
					#had to remove because of tophat
					#&&
					#!m/sequence\.\d+\./
				 } @allFiles;


@allFilesFiltered = @allFiles;
@allFilesFiltered = grep {s/^\/storage.+(flowcells|incoming|analysis)//} @allFilesFiltered;


for my $i (0.. $#allFilesFiltered)
{
	$cleanToFullPathHash{$allFilesFiltered[$i]} = $allFiles[$i];
}

my %seen = (); @allFilesFiltered = grep { ! $seen{ $_ }++ } @allFilesFiltered;

print "<?xml version=\"1.0\"?><report flowcell=\"$flowcell\" lanes=\"12345678\">";
if($doQC)
{
	find("\\.csv");
	qcreports();
}
elsif($doTDF)
{
	find("\\.tdf");
}
else
{
	#find("\\.htm","\\.csv","sequence\\.txt","export\\.txt","eland","\\.map","\\.bam","\\.sam","\\.wig","\\.peaks","\\.tdf","\\.bed","\\.g[tf]f","\\.srf","qseqs_archive");
	find("\\.csv","sequence\\.txt","export\\.txt","eland","\\.map","\\.bam","\\.sam","\\.wig","\\.peaks","\\.tdf","\\.bed","\\.g[tf]f","\\.srf","qseqs_archive","\\.expr");
}

print "</report>";


sub find
{
	for my $regex (@_)
	{
		my @results = grep {m/$regex/} @allFilesFiltered;
		for $hit (@results)
		{
			my $fullPath = $cleanToFullPathHash{$hit};
			my ($base,$dir) = fileparse($hit);
			$dir =~ /\/.+?\/(.+$)/;
			my $location = $1||$dir;
			print "<file base=\"$base\" dir=\"$dir\" label=\"$location\" type=\"unknown\" fullpath=\"$fullPath\"/>";
		}
	}
}

sub qcreports
{
	my @qcFileNames = grep {m/qcmetrics\.csv/} @allFiles;
	my @summaryFiles = grep {m/\/Summary\.xml/} @allFiles;
	my @RTAConfigFiles = grep {m/\/RTAConfiguration\.xml/} @allFiles;
	my $RTAConfigFile = pop @RTAConfigFiles;
	my $summaryFile = pop @summaryFiles;
		
	for my $qcFileName (@qcFileNames)
	{
		#Check cache to see if we already have this qc report.
		if(!$findCache{$qcFileName} || !$findCache{$$qcFileName . "WriteTime"} || (time() - $findCache{$qcFileName . "WriteTime"} >  $cache_expire))
		{
			my $reportContents = ""; 
			my @qcFileContent;
			open(my $qcFile, "<$qcFileName") || die;
			my $headerLine = <$qcFile>;
			chomp $headerLine;
			while(my $line = <$qcFile>)
			{
				chomp $line;
				push @qcFileContent, $line;
			}
			
			#add qc from summary.xml
			$summaryRef = XMLin($summaryFile, KeyAttr => "laneNumber") if -e $summaryFile;
			$RTAConfigRef = XMLin($RTAConfigFile) if -e $RTAConfigFile;
			$headerLine .= ",Date_Sequenced,Lane_Yield,Clusters_Raw,Clusters_PF,Percent_Clusters_PF,Int_1Cycle,Int_20Cycles,Phasing,Prephasing,ControlLane,ReadType";
			for my $i (0..$#qcFileContent)
			{				
				$qcFileContent[$i] =~ /^.+?,(\d+),/;
				my $laneNum = $1;
				my $date = $summaryRef->{Date} || "Mon Jan 00 00:00:00 0000";
				$date =~ s/^.{4}//;
				$date =~ s/\d+:\d+:\d+ //;
				$qcFileContent[$i] .= ",$date,";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{laneYield}) . ",";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{clusterCountRaw}->{mean}) . ",";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{clusterCountPF}->{mean}) . ",";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{percentClustersPF}->{mean}) . "%,";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{oneSig}->{mean}) . ",";
				$qcFileContent[$i] .= getValue($summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{signal20AsPctOf1}->{mean}) . "%,";
				$qcFileContent[$i] .= getValue($summaryRef->{ExpandedLaneSummary}->{Read}->{Lane}->{$laneNum}->{phasingApplied}) . "%,";
				$qcFileContent[$i] .= getValue($summaryRef->{ExpandedLaneSummary}->{Read}->{Lane}->{$laneNum}->{prephasingApplied}) . "%,";
				$qcFileContent[$i] .= getValue($RTAConfigRef->{ControlLane}) . ",";
				$qcFileContent[$i] .= getValue($RTAConfigRef->{ReadType});
				
				my $genomeCmd  = "cat " . dirname($qcFileName) . "/../../work*.txt | grep Lane.$laneNum" . ".Reference";
				my $genome = `$genomeCmd`;
				$genome =~ /\=*(\S+)\s*$/;
				$genome = $1;
				if($genome)
				{
					$headerLine .= ",genome";
					$qcFileContent[$i] .= "," . basename($genome);
				}
			}
			
			$reportContents .= "<qcreport path=\"$qcFileName\">";
			my @header = split(/,/,$headerLine);
			foreach my $line (@qcFileContent)
			{			
				$reportContents .= "<qcEntry>";
				my @fields = split(/,/,$line);
				for my $i (0..$#fields)
				{	
					if($fields[$i] =~ /^\d\d\d\d\d\d+/)
					{
						$fields[$i] = $fields[$i] / 1000000;
						$fields[$i] = sprintf "%.2f", $fields[$i];					
						$fields[$i] .= "M";	
					}
					elsif($fields[$i] =~ /^0\.\d\d\d\d+$/)
					{
						$fields[$i] = $fields[$i] * 100;
						$fields[$i] = substr($fields[$i],0,5) . "%";	
					}
					$reportContents .=  "<$header[$i]>$fields[$i]</$header[$i]>";
				}
				$reportContents .=  "</qcEntry>";			
			}
			$reportContents .=  "</qcreport>";
			$findCache{$qcFileName} = $reportContents;
			$findCache{$qcFileName . "WriteTime"} = time();
		}
		print $findCache{$qcFileName};	
	}
	
}

sub getValue
{
	return $_[0] || "NA";
}