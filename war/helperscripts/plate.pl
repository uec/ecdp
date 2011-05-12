#!/usr/bin/perl
require LWP::UserAgent;
use DB_File;
use XML::LibXML;
use XML::LibXSLT;

tie %pageCache, "DB_File", "/tmp/genURLcache", O_RDWR|O_CREAT, 0666, $DB_HASH;
$cache_expire = 2000000;
$totalCalls = 0;
$cacheMisses = 0; 

$report = getGeneusNoCache("http://epilims.usc.edu:8080/api/v1/processes?type=Hyb%20Multi%20BC2");
#$report = "<processes><process uri=\"http://epilims.usc.edu:8080/api/v1/processes/TRP-DTM-110405-122-809\" limsid=\"TRP-DTM-110405-122-809\"/>\n<process uri=\"http://epilims.usc.edu:8080/api/v1/processes/BC2-AHX-110511-122-844\" limsid=\"BC2-AHX-110511-122-844\"/></processes>";
if($report eq $pageCache{"PlateAllEntries"} && $pageCache{"PlateFinalXML"})
{
#	print $pageCache{"PlateFinalXML"};
#	exit;
}

$pageCache{"PlateAllEntries"} = $report;

@tags = (    qr/\<(process)\suri=\"(.+?)\".+?\>/, 
             qr/\<(output)\suri=\"(.+?)\".+?\>/, 
             qr/\<(sample)\suri=\"(.+?)\".+?\>/, 
             qr/\<(project)\suri=\"(.+?)\".+?\>/,
             qr/\<(input)\suri=\"(.+?)\".+?<\/input>/,
             qr/\<(container)\suri=\"(.+?)\".+?\>/);
             #qr/\<placement\suri=\"(.+?)\".+?<\/placement>/, 
             
for $entity (@tags)
{
        print STDERR "expanding $entity\n";
        while($report =~ m/$entity/g)
        {
        		my $tagType = $1;
                my $url = $2;
                my $tag = quotemeta($&);
                my $replacement = "<$tagType>" . getGeneus($url) . "</$tagType>\n";
                $report =~ s/$tag/$replacement/g || die "failed";                
        }
}
$report =~ s/\<(\/*)\w+\:(\w+)/\<$1$2/g;
$report =  "<\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" . $report;
my $xslt = XML::LibXSLT->new();
my $xml = XML::LibXML->new();
my $source = $xml->parse_string($report);
my $style_doc = $xml->parse_file('/opt/tomcat6/webapps/ECCP/helperscripts/plateXML.xslt');
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
$pageCache{"PlateFinalXML"} = $stylesheet->output_as_bytes($results);
 
#$pageCache{"MethCachedFinalXML"} = $report;
print $pageCache{"PlateFinalXML"};
print STDERR "calls: $totalCalls     cacheMisses: $cacheMisses\n";







untie %pageCache;

sub getGeneus
{
		$totalCalls++;
		print STDERR "calls: $totalCalls     cacheMisses: $cacheMisses\n" if($totalCalls % 100 == 0);
		
        my $url = shift @_;
        return $pageCache{$url} if $pageCache{$url} && $pageCache{$url . "WriteTime"} && (time() - $pageCache{$url . "WriteTime"} < $cache_expire);
        $cacheMisses++;
        my $ua = LWP::UserAgent->new;
        $ua->credentials("epilims.usc.edu:8080","GLSSecurity",'zack'=>'genzack');
        my $response = $ua->get($url);
        my $ret = $response->content;
        $ret =~ s/\<\?xml.+?\>//;
        $pageCache{$url} = $ret;
        $pageCache{$url . "WriteTime"} = time();
        return $ret;
}

sub getGeneusNoCache
{
	    my $url = shift @_;
        my $ua = LWP::UserAgent->new;
        $ua->credentials("epilims.usc.edu:8080","GLSSecurity",'zack'=>'genzack');
        my $response = $ua->get($url);
        my $ret = $response->content;
        $ret =~ s/\<\?xml.+?\>//;
        return $ret;
}
