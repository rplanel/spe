#!/usr/bin/env perl

use strict;
use Data::Dumper;

my $progenomes = $ARGV[0];
my $outDir = $ARGV[1] || 'out';


mkdir $outDir;

open (my $GENOMES, '<', $progenomes) or die ("Cannot open the file $progenomes\nERROR:$!");
my $currentGenomes;
my $OUT;
while (my $l = <$GENOMES>) {
  chomp $l;
  if ($l =~ /^>/) {
    $l =~ s/^>//g;
    my ($taxId, $projId) = split(/\./, $l);
    my $genomesId = $taxId.'-'.$projId.'.fna';
    if (!defined $currentGenomes || $currentGenomes ne $genomesId) {
      $currentGenomes = $genomesId;
      open ($OUT, '>', $outDir.'/'.$currentGenomes) or die ("Cannot open the file $currentGenomes\nERROR:$!");
      print $OUT ">$taxId.$projId\n";
    }
  }
  else {
    print $OUT $l,"\n";
  }
}
