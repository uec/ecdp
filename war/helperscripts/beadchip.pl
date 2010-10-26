#!/usr/bin/perl
require LWP::UserAgent;
use DB_File;
use XML::LibXML;
use XML::LibXSLT;
tie %pageCache, "DB_File", "/tmp/genURLcache", O_RDWR|O_CREAT, 0666, $DB_HASH;
$cache_expire = 2000000;
$totalCalls = 0;
$cacheMisses = 0; 

$report = getGeneusNoCache("http://epilims.usc.edu:8080/api/v1/containers?type=Beadchip%201%20x%2012");
if($report eq $pageCache{"MethAllEntries"} && $pageCache{"MethCachedFinalXML"})
{
	print $pageCache{"MethCachedFinalXML"};
	exit;
}

$pageCache{"MethAllEntries"} = $report;

@tags = (qr/\<container\suri=\"(.+?)\".+?<\/container>/, qr/\<placement\suri=\"(.+?)\".+?<\/placement>/, qr/\<sample\suri=\"(.+?)\".+?\>/, qr/\<project\suri=\"(.+?)\".+?\>/);
for $entity (@tags)
{
        while($report =~ m/$entity/g)
        {
                my $url = $1;
                my $tag = quotemeta($&);
                my $replacement = getGeneus($url);
                $report =~ s/$tag/$replacement/g || die "failed";                
        }
}
$report =~ s/\<(\/*)\w+\:(\w+)/\<$1$2/g;
$report =  "<\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" . $report;
my $xslt = XML::LibXSLT->new();
my $xml = XML::LibXML->new();
my $source = $xml->parse_string($report);
my $style_doc = $xml->parse_file('/opt/tomcat6/webapps/ECCP/helperscripts/beadchipXML.xslt');
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
$pageCache{"MethCachedFinalXML"} = $stylesheet->output_as_bytes($results);
print $pageCache{"MethCachedFinalXML"};
print STDERR "calls: $totalCalls     cacheMisses: $cacheMisses\n";

untie %pageCache;

sub getGeneus
{
		$totalCalls++;
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