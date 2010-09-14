#!/usr/bin/perl
require LWP::UserAgent;
use DB_File;
use XML::libXSLT;
use XML::LibXML;
tie %pageCache, "DB_File", "/tmp/genURLcache", O_RDWR|O_CREAT, 0666, $DB_HASH;
$cache_expire = 14400;


# or die "Cannot open file 'fruit': $!\n";
$report = getGeneus("http://epilims.usc.edu:8080/api/v1/processes?type=GA%20Analysis%20Workflow");
@tags = (qr/\<process\suri=\"(.+?)\".+?\>/, qr/\<input\suri=\"(.+?)\".+?<\/input>/, qr/\<sample\suri=\"(.+?)\".+?\>/, qr/\<project\suri=\"(.+?)\".+?\>/);
for $entity (@tags)
{
	while($report =~ m/$entity/g)
	{		
		my $url = $1;
		my $tag = quotemeta($&);
		#print STDERR $tag . "\n";
		my $replacement = getGeneus($url);
		#print STDERR $replacement . "\n";
		$report =~ s/$tag/$replacement/g || die "failed";
	}	
}
$report =~ s/\<(\/*)\w+\:(\w+)/\<$1$2/g;
$report =  "<\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" . $report;
my $xslt = XML::LibXSLT->new();
my $source = XML::LibXML->load_xml(string => $report);
my $style_doc = XML::LibXML->load_xml(location=>'/opt/tomcat6/webapps/ECCP/helperscripts/flowcellXML.xslt', no_cdata=>1);
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
print $stylesheet->output_as_bytes($results);


untie %pageCache;

sub getGeneus
{	
	my $url = shift @_;
	return $pageCache{$url} if $pageCache{$url} && $pageCache{$url . "WriteTime"} && (time() - $pageCache{$url . "WriteTime"} < $cache_expire);
	my $ua = LWP::UserAgent->new;
	$ua->credentials("epilims.usc.edu:8080","GLSSecurity",'zack'=>'genzack');
	my $response = $ua->get($url);
	my $ret = $response->content;
	$ret =~ s/\<\?xml.+?\>//;
	$pageCache{$url} = $ret;
	$pageCache{$url . "WriteTime"} = time();
	return $ret;
}