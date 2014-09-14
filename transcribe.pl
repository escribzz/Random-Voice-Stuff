#!/usr/bin/perl

#created by Erik Knight to use google for voicemail transcription and auto attendant transcription.
#proxies may be required if used at high volume

$filename=$ARGV[0];
$filetest=0;
open(LENGTH,"/usr/local/bin/soxi -D $filename |");
	foreach $line (<LENGTH>){
		$size=$line;
		$size1=$line;
		$filetest=1;
		}
close LENGTH;
	if ($filetest eq 0){
		exit(0);
		}
$size1 = sprintf "%.0f",$size1;
$size = sprintf "%.0f0",$size/10;
$size =$size+11;
$runcount=0;
$trim1=0;
$sizes=0;
while($size > $sizes) {
$sizes=$sizes+10;
	if($sizes > $size1){
	   $sizes = $size1;
	   $size = $size1;
		}
($file,$extension)=split(/\./,$filename);
system("/usr/local/bin/sox $file.WAV -b 16 -r 8000  -t flac $file$runcount.flac trim $trim1 10");
$trim1=$sizes;
system("/usr/bin/wget -q --timeout=20 --post-file='$file$runcount.flac' --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7' --header='Content-Type: audio/x-flac; rate=8000;' -O '$file$runcount.json' --no-check-certificate 'https://www.google.com/speech-api/v1/recognize?client=chromium&lang=en-US&maxresults=1&pfilter=1'");
open(IN,"$file$runcount.json");
foreach $line (<IN>){
	$statement1="";
	$statement="";
	($start,$statement1)=split(/:\[/,$line);
	($statement,$confidence1)=split(/\",\"confidence\":/,$statement1);
	$statement =~ s/\{\"utterance\":\"//g;
	$statement =~ s/\"},/. /g;
	$statement =~ s/\"\}\]\}/./g;
	$confidence1 =~ s/\}\]\}//g;
	}
close IN;
system("/bin/rm -f $file$runcount.flac");
system("/bin/rm -f $file$runcount.json");
	$runcount++;
	$confidence=$confidence+$confidence1;
	$confidence1=0;
	if ($message){
	$message=$message." ".$statement;
	}
	else
	{
	$message=$statement;
	}
	$statement="";
	}
	if ($message eq ""){
		$message="Unable To Transcribe This Message\n";
		}
	#capitalize the first letter before we print
	$message =~ s/^([a-z])/\u$1/;
	$message =~ s/([a-z])^/$1\./;
	#Internal Word Filter
	$message =~ s/Penis/#####/ig;
	$confidence=$confidence/$runcount;
	$confidence=$confidence*100;
	$accuracy = substr($confidence, 0, 4);
	$accuracy = $accuracy - $runcount;
print "\n";
print $message;
print "\n\nTranscription Accuracy: $accuracy\%";
