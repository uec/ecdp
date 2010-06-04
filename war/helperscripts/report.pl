#!/usr/bin/perl
use File::Basename;
use XML::Simple;

$flowcell = $ARGV[0];
$doQC = $ARGV[1];

@allFilesFiltered = @allFiles = split(/\n/,`/usr/bin/locate -d /storage/index/mlocate.db $flowcell | /bin/grep -v Thumbnail_Images | /bin/grep -v .cif | /bin/grep -v .hpc-pbs.usc.edu`);
@allFilesFiltered = grep {s/^\/storage.+(flowcells|incoming)//} @allFilesFiltered;
my %seen = (); @allFilesFiltered = grep { ! $seen{ $_ }++ } @allFilesFiltered;


print "<?xml version=\"1.0\"?><report flowcell=\"$flowcell\" lanes=\"12345678\">";
if($doQC)
{
	find("\\.csv");
	qcreports();
}
else
{
	find("\\.htm","\\.csv","sequence\\.txt","export\\.txt","eland","\\.map","\\.bam","\\.sam","\\.wig","\\.peaks","\\.bed","\\.g[tf]f","\\.srf","qseqs_archive");
}

print "</report>";


sub find
{
	for my $regex (@_)
	{
		my @results = grep {m/$regex/} @allFilesFiltered;
		for $hit (@results)
		{
			my ($base,$dir) = fileparse($hit);
			$dir =~ /\/.+?\/(.+$)/;
			my $location = $1||$dir;
			print "<file base=\"$base\" dir=\"$dir\" label=\"$location\" type=\"unknown\"/>";
		}
	}
}

sub qcreports
{
	my @qcFileNames = grep {m/qcmetrics\.csv/} @allFiles;
	my @summaryFiles = grep {m/\/Summary\.xml/} @allFiles;
	my $summaryFile = pop @summaryFiles;
	for my $qcFileName (@qcFileNames)
	{
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
		$summaryRef = XMLin($summaryFile, KeyAttr => "laneNumber");
		$headerLine .= ",Date_Sequenced,Lane_Yield,Clusters_Raw,Clusters_PF,Percent_Clusters_PF,Int_1Cycle,Int_20Cycles,Phasing,Prephasing";
		for my $i (0..$#qcFileContent)
		{
			$qcFileContent[$i] =~ /^.+?,(\d+),/;
			my $laneNum = $1;
			my $date = $summaryRef->{Date};
			$date =~ s/^.{4}//;
			$date =~ s/\d+:\d+:\d+ //;
			$qcFileContent[$i] .= ",$date,";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{laneYield} . ",";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{clusterCountRaw}->{mean} . ",";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{clusterCountPF}->{mean} . ",";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{percentClustersPF}->{mean} . "%,";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{oneSig}->{mean} . ",";
			$qcFileContent[$i] .= $summaryRef->{LaneResultsSummary}->{Read}->{Lane}->{$laneNum}->{signal20AsPctOf1}->{mean} . "%,";
			$qcFileContent[$i] .= $summaryRef->{ExpandedLaneSummary}->{Read}->{Lane}->{$laneNum}->{phasingApplied} . "%,";
			$qcFileContent[$i] .= $summaryRef->{ExpandedLaneSummary}->{Read}->{Lane}->{$laneNum}->{prephasingApplied} . "%";
			
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
		
		#print $_ . "\n" for (
		
		
		print "<qcreport path=\"$qcFileName\">";
		my @header = split(/,/,$headerLine);
		foreach my $line (@qcFileContent)
		{			
			print "<qcEntry>";
			my @fields = split(/,/,$line);
			for my $i (0..$#fields)
			{
				if($fields[$i] =~ /^0\.\d\d\d\d+$/)
				{
					$fields[$i] = $fields[$i] * 100;
					$fields[$i] = substr($fields[$i],0,5) . "%";	
				}
				print "<$header[$i]>$fields[$i]</$header[$i]>";
			}
			print "</qcEntry>";			
		}
		print "</qcreport>";	
	}
}