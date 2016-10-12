#!/usr/bin/env perl

use strict;

my $edges     = $ARGV[0];
my $distanceT = $ARGV[1];
my $pvalueT   = $ARGV[2];
open (my $EDGES, '<', $edges) or die ("Cannot open the file $edges\nERROR:$!");


my $currentNodeId;
my $nodeIdRecord = {};
print "reference-ID\tquery-ID\tdistance\tp-value\tshared-hashes\n";
while (my $l = <$EDGES>) {
  chomp $l;
  my ($oid1, $oid2, $dist, $pval) = split(/\t+/,$l);




  if (!defined $currentNodeId || $oid2 != $currentNodeId) {
      $currentNodeId = $oid2;
      $nodeIdRecord->{$oid2}++;
  }
  if (
      $oid1 == $oid2
      || (!exists $nodeIdRecord->{$oid1} 
      && $dist <= $distanceT
      && $pval <= $pvalueT)
      ) {
    print "$l\n";
  }
  else {
    next;
  }
}

