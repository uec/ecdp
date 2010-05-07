#!/usr/bin/perl
use File::Basename;
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
	find("\\.htm","\\.csv","sequence\\.txt","export\\.txt","eland","\\.map","\\.bam","\\.wig","\\.bed","\\.g[tf]f","\\.srf","qseqs_archive");
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
	my @qcFiles = grep {m/qcmetrics.csv/} @allFiles;
		
	for my $qcFileName (@qcFiles)
	{
		print "<qcreport path=\"$qcFileName\">";
		open(my $qcFile, "<$qcFileName") || die;
		my @header = split(/,/,<$qcFile>);
		chomp @header;
		while(my $line = <$qcFile>)
		{
			chomp $line;
			print "<qcEntry>";
			my @fields = split(/,/,$line);
			for my $i (0..$#fields)
			{
				print "<$header[$i]>$fields[$i]</$header[$i]>";
			}
			print "</qcEntry>";			
		}
		print "</qcreport>";	
	}
}
