#!/usr/bin/perl
# Written by Erik Knight to do LRN lookups & Caching. 
#
# extensions.conf example:
# exten => s,1,OGI,lookup.ogi
# exten => s,2,Dial,Zap,1
#
use DBI;
#use callweaver::OGI;
use LWP::UserAgent;
use Cache::Memcached;
  $memd = new Cache::Memcached {
    'servers' => [ "127.0.0.1:11211"],
    'debug' => 0,
    'compress_threshold' => 10_000,
  };

my $dbh = DBI->connect("dbi:mysql:host=127.0.0.1:Database","User",'Password');

# TIMEOUT is maximum number of seconds for http requests (we don't want to take too long)
$intra=0;
$search="IteRate";
$TIMEOUT = 3;
alarm(3);
$VERSION = '0.03';
#$OGI = new CallWeaver::OGI;

#my %input = $OGI->ReadParse();
$exten = $input{'extension'};
$clid = $input{'callerid'};

$clid=6025387093;
$exten=$ARGV[0];;

$memspot="1".$exten;

$memory = $memd->get($memspot);
if ($memory){
        #found in cache go ahead and use the value
	$exten=$memory;
        }
        else
        {
        #we don't have it in the 7 day cache look it up and save the value in the cache for 7 days
eval {
                        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
                        alarm 2;
open(IN,"/usr/bin/curl 'http://api1.east.alcazarnetworks.com/api/lrn?key=APIKEYHERE=$memspot'|");
foreach $line (<IN>){
		#chop the one from the string
	  	$line =~ s/.//;	
		$memd->set($memspot, $line, 604800);
		$exten=$line;
                }
		alarm 0;
             };

        }

print "$exten\n";

$npa = substr $exten, 0, 3;
$nxx = substr $exten, -7, 3;

$cnpa = substr $clid, 0, 3;
$cnxx = substr $clid, -7, 3;

$newcpna = $cnpa;

if (($cnpa eq $npa) || ($newcpna eq 800) || ($newcpna eq 877) || ($newcpna eq 888) || ($newcpna eq 866) || ($newcpna eq 855) || ($cnpa !~ /\d{3}/) || ($cnxx !~ /\d{3}/)){
	$intra=1;
	}
	else
	{
	$state = "select R1.State from RateCenters R1 INNER JOIN RateCenters R2 ON R1.State = R2.State where R1.NPA=$cnpa and R1.NXX=$cnxx AND R2.NPA=$npa And R2.NXX=$nxx";
	$ztha = $dbh->prepare($state);
                $ztha->execute() or print "Fail\n" and die;
                my $array_stuffa = $ztha->fetchall_arrayref();
                foreach my $stuffa (@$array_stuffa) {
                my ($ratecenter)=@$stuff;
		$intra=1;
		}
	}

	if ($intra eq 1){
		$search="ItaRate";
		}
#select info from our LCR Datbase

$sip = "select RouteName,ProviderPrefix from LCRTerm where NPA=$npa and NXX=$nxx Order by RouteOveride DESC,$search limit 1";

                $zth = $dbh->prepare($sip);
                $zth->execute() or print "Fail\n" and die;
                my $array_stuff = $zth->fetchall_arrayref();
                foreach my $stuff (@$array_stuff) {
                my ($routename,$providerprefix)=@$stuff;
			if ($providerprefix eq 0){
				$providerprefix ='';
				}
		print "$routename\n";
	#	$OGI->exec('Set', "routename=\"$routename\"");
	#	$OGI->exec('Set', "providerprefix=\"$providerprefix\"");

		}
$memd->disconnect_all;
exit(0);
