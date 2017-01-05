#!/usr/bin/env perl

use strict;
use Data::Dumper;
use PerlIO::gzip;

my $progenomes = $ARGV[0];
my $outDir = $ARGV[1] || 'split-progenomes';


mkdir $outDir;
print STDERR $progenomes,"\n";
open (my $GENOMES, '<:gzip', $progenomes) or die ("Cannot open the file $progenomes\nERROR:$!");
my $currentGenomes;
my $OUT;
my $header;
my $is_header_print = 0;
while (my $l = <$GENOMES>) {
  # print STDERR $l,"|\n";
  chomp $l;
  if ($l =~ /^>/) {
    $l =~ s/^>//g;
    $is_header_print = 0;
    my ($taxId, $projId) = split(/\./, $l);
    my $genomesId = $taxId.'.'.$projId.'.fna.gz';
    ##print STDERR $genomesId,"\n";
    if (!defined $currentGenomes || $currentGenomes ne $genomesId) {
      $currentGenomes = $genomesId;
      close $OUT if defined $OUT;
      open ($OUT, '>:gzip', $outDir.'/'.$currentGenomes) or die ("Cannot open the file $currentGenomes\nERROR:$!");
    }
    $header = ">$l\n";
    ## print $OUT ">$l\n";
  }
  else {
    $l =~ s/N//g;
    if ($l ne '') {
      if (!$is_header_print) {
	print $OUT $header;
	$is_header_print = 1;
      }
      print $OUT $l,"\n";
    }
    ##print STDERR $l,"\n";
  }
}
