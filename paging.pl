#!/usr/bin/perl


# This is for use for overhead paging and the laid out comvoice dialplan
# Be sure to chmod 777 /var/spool/asterisk/outgoing before you use this or it won't work
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$mon++;
$year = $year +1900;
$date = $year."-".$mon."-".$mday;
$time = $hour.":".$min.":".$sec;

use Getopt::Std;
use Getopt::Long;
my ($exten,$account,$channel);
$exten = $chan = $account = '';

GetOptions("t=s">\$accounts,"c=s"=>\$channel,"e=s"=>\$exten,"a=s"=>\$account);

($phoneid,$junk) = split(/\-/,$channel);

#our channels are -1 -2 etc

$channel1=$phoneid."-1";
$channel2=$phoneid."-2";


open(OUT,">/var/spool/asterisk/outgoing/apage$account");
print OUT <<EOH;
Channel: SIP/$channel1 
CallerID: OverheadPage <5555555555> 
MaxRetries: 1 
RetryTime: 30 
WaitTime: 30 
Context: $account 
Extension: $exten 
Priority: 10 
EOH
close OUT;

open(OUT,">/var/spool/asterisk/outgoing/bpage$account");
print OUT <<EOH;
Channel: SIP/$channel2 
CallerID: OverheadPage <5555555555>
MaxRetries: 1
RetryTime: 30
WaitTime: 30
Context: $account
Extension: $exten
Priority: 10
EOH
close OUT;


