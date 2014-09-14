#!/usr/bin/perl
#Erik Knight second file called to transcribe asterisk voicemail with google


use strict;

my $boundary="none";
my $type="none";
my $fname="none";
my $location="nowhere";
my $fscram="9999";

foreach my $line (<STDIN>) {

   chomp;

   if ($line =~ /^Content-type:\s.*\sboundary=.*$/i) {

        $line =~ s/\"//g;
        ($boundary) = $line=~ m/.*=(.*)$/;
        next;

   } elsif (($line =~ /$boundary/) && ($location =~ /nowhere/)){
        $location="header";
        next;
   }

   if ($location =~ /header/) {
        if ($line =~ /^Content-type:\s.*;\s.*$/i) {

                ($type) = $line=~ /^Content-type:\s(.*);\s.*$/i;

        } elsif ($line =~ /^Content-Disposition:\sattachment;\s.*$/i) {

                $line =~ s/\"//g;
                ($fname) = $line=~ /^Content-Disposition:\sattachment;\sfilename=(.*)$/i;
		$fscram=int(rand(9999));
		$fname=$fscram.$fname;

        } else {
                next unless ($line =~ /^$/) ;
                if ( not $fname =~ /none/) {
                        $location="body";
                        open(ATT, ">.".$fname.".b64") || die "Could not open file\n";
                        print ATT "begin-base64 0644 ". $fname ."\n";
                }else {
                        $location="nowhere";
                }
        }

  } elsif ($location =~ /body/) {

        if ($line =~ /$boundary/){
                print ATT "====\n";
                close (ATT);
                my @args = ("uudecode", ".".$fname.".b64");
                system(@args) == 0
                         or die "system @args failed: $?" ;
                print $fname."\n";

                $fname="none";
                $type="none";

        if (not $line =~ /$boundary--/){
                $location="header";
        }

        } else {
                print ATT $line;
        }

  }

}
