#!/usr/bin/perl
# Created by Erik Knight to generate SMS messages via LRN
#
# extensions.conf example:
# exten => s,1,OGI,lookup.ogi
# exten => s,2,Dial,Zap,1
#
# Be very specific with your db entries. If you put "Wireless" in there or "AZ" for search terms they will always hit Be specific like "Verizon"
alarm(3);
use DBI;
use LWP::UserAgent;
$callerid="6025555555";
$text="This is a test text message";

my $dbh = DBI->connect("dbi:mysql:host=127.0.0.1:DATABASE","USER",'PASSWORD');

# TIMEOUT is maximum number of seconds for http requests (we don't want to take too long)
$intra=0;
$search="IteRate";
$TIMEOUT = 3;
$VERSION = '0.03';
$exten="6024053514";

$memspot="1".$exten;

        #we don't have it in the 7 day cache look it up and save the value in the cache for 7 days
open(IN,"/usr/bin/curl --connect-timeout 2 'http://api1.east.alcazarnetworks.com/api/lrn?key=MYKEY=$memspot&extended=true'|");
foreach $line (<IN>){
                #chop the one from the string
                $line =~ s/.//;
                $company=$line;
                }
($lrn,$ocn,$lata,$city,$state,$jurisdiction,$lec,$junk)=split(/<br>/,$company);
close IN;
my @tokens = split / /, $lec;
# Print out the tokens we've extracted by 
# splitting the string, one per line.
foreach my $token(@tokens) {
if ($token eq "-"){
#do nothing
}else{
$sip = "select Contact from SMS where SearchTerm like '%$token%' limit 1";
print $sip;
                $zth = $dbh->prepare($sip);
                $zth->execute() or print "Fail\n" and die;
                my $array_stuff = $zth->fetchall_arrayref();
                foreach my $stuff (@$array_stuff) {
                my ($contact1)=@$stuff;
		$contact=$contact1;
		}
	    }
	}
$contact=$exten."@".$contact;
#system("/usr/local/bin/sendEmail -l /var/log/sendEmail.log -q -s 127.0.0.1 -f noreply\@provider.com -t $contact -u \"Text From $callerid\" -m \"$text\"");
$subject="Text From $callerid";
$from="noreply\@provider.com";
 	$sendmail = '/usr/sbin/sendmail';
# 	open(MAIL, "|$sendmail -oi -f noreply\@provider.com -t");
# 		print MAIL "From: $from\n";
# 		print MAIL "To: $contact\n";
# 		print MAIL "Subject: $subject\n\n";
# 		print MAIL "$text\n";
# 	close(MAIL);
print $contact;
exit(0);
