#!/usr/bin/perl

#Written by Erik Knight in September 2013 when Ammo Crisis was on. This tracks and pulls common inventory on the walmart system that may not be availible on the website and app. If its set up on a cron it will email you ever hour of changes on stores you are watching.

use DBI;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon++;
$year = $year +1900;
$date = $year."-".$mon."-".$mday;
$time = $hour.":".$min.":".$sec;


#stores zipcodes products
$productcode="10984471"; #budwiser Test
$email='noname@nonet.com';
$message="";

#Tracking multiple products
@myProductcodes = ('16783170', '17128628', '17175595', '17175595', '21145608', '17128629', '21638833', '22027232', '17617401', '16930262');
#Tracking stores in the 50 mi radius of these zipcodes
@myZipcodes = ('85282', '85015', '85027', '85338');

 foreach (@myProductcodes) {
        $productcode = $_;


 foreach (@myZipcodes) {
 	$zipcode = $_;


$productdescription="";
$storeid="";
$availibilitycode="";
$stockstatus="";
$notavail="";
$outofstock="";
$reorder="";
$fullstreet="";
$a=0;
system("/usr/local/bin/wget -q --timeout=20 --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7' -O '/tmp/walmart' --no-check-certificate 'http://www.walmart.com/catalog/storeInventoryNew.do?&rnd=1361893120926&single_line_address=$zipcode&item_id=$productcode&fromSlap=false&showSlap=true&selected_variant_id=$productcode&zip=&city=&state='");
sleep(5);
open(IN,"/tmp/walmart");
foreach $line (<IN>){

$variable="";
$value="";

if ($line =~ m/storeId/ig){
	($variable,$value)=split(/:/,$line);
	$variable =~ s/\'//g;
	$value =~ s/\'//g;
	$value =~ s/\,//g;
	chomp($value);
	$storeid=$value;
	}	

if ($line =~ m/availbilityCode/ig){
		($variable,$value)=split(/:/,$line);
 	        $variable =~ s/\'//g;
     	        $value =~ s/\'//g;
		$value =~ s/\,//g;
		chomp($value);
         	$availibilitycode=$value;
		}


if ($line =~ m/stockStatus/ig){ 
		($variable,$value)=split(/:/,$line);
                $variable =~ s/\'//g;
                $value =~ s/\'//g;
		$value =~ s/\,//g;
		chomp($value);
                $stockstatus=$value;
                }

if ($line =~ m/isNotAvailable/ig){
		($variable,$value)=split(/:/,$line);
                $variable =~ s/\'//g;
                $value =~ s/\'//g;
		$value =~ s/\,//g;
		chomp($value);
                $notavail=$value;
                }

if ($line =~ m/isOutOfStock/ig){ 
		#true/false
		($variable,$value)=split(/:/,$line);
                $variable =~ s/\'//g;
                $value =~ s/\'//g;
		$value =~ s/\,//g;
		chomp($value);
                $outofstock=$value;
                }
		
if ($line =~ m/isReplenishable/ig){
                #true/false
                ($variable,$value)=split(/:/,$line);
                $variable =~ s/\'//g;
                $value =~ s/\'//g;
		$value =~ s/\,//g;
		chomp($value);
                $reorder=$value;
                }
if ($line =~ m/ItemDesc/g){
		$value=$line;
		$value =~ s/\<div class=\"ItemDesc\">//g;
		$value =~ s/\<\/div>//g;
		chomp($value);
		$productdescription = $value;
		}

if ($line =~ m/fullStreet/ig){
                ($variable,$value)=split(/:/,$line);
                $variable =~ s/\'//g;
                $value =~ s/\'//g;
		$value =~ s/\}//g;
		$value =~ s/\,//g;
		chomp($value);
                $fullstreet=$value;
                }
	if ($line =~ m/businessHours/g){
		$a++;
                if ($availibilitycode != 0){
                	$storemessage[$a]="($productcode $productdescription) <Store # $storeid> $fullstreet has changed the supply status to $stockstatus ($availibilitycode)\n";
                        }
		$storeid="";
		$availibilitycode="";
		$stockstatus="";
		$notavail="";
		$outofstock="";
		$reorder="";
		$fullstreet="";
		}

		
		
}
close IN;
system("rm /tmp/walmart");
$i=0;
while  ( $i != $a) {
	$i++;
	$message=$message.$storemessage[$i];
	$lastmessage=$message;
		}
	}
}

if ($message) {
system("echo \"$message\" >> /tmp/ammo.txt");
my $file = '/tmp/ammo.txt';
my %seen = ();
{
   local @ARGV = ($file);
   local $^I = '.bac';
   while(<>){
      $seen{$_}++;
      next if $seen{$_} > 1;
      print;
   }
}

$sendemail=0;
$newmessage="";
open(INN,"/usr/bin/diff /tmp/ammo.txt.old /tmp/ammo.txt |");
foreach $linez (<INN>){
	if (length($linez) < 10){
		$linez ="";
		}
	$linez =~ s/\< \(/Removed: \(/g;
	$linez =~ s/\> \(/Added: \(/g; 
	$newmessage=$newmessage.$linez;
	$sendemail=1;
	}
close INN;


if ($sendemail eq 1){
system("echo \"Inventory Changes:\n\" >> /tmp/newammo.txt");
system("echo \"$newmessage\" >> /tmp/newammo.txt");
system("echo \"\n\n\n Current Inventory:\n\" >> /tmp/newammo.txt");
system("cat /tmp/ammo.txt >> /tmp/newammo.txt");  
system("/usr/local/bin/sendEmail -l /var/log/sendEmail.log -q -s 127.0.0.1 -f info\@dirtsearch.org -t $email -u \"WalMart Inventory Change Report $date $time\" -o \"message-file=/tmp/newammo.txt\"");
		}
system("mv /tmp/ammo.txt /tmp/ammo.txt.old");
system("rm /tmp/newammo.txt");
	}

