#!/usr/bin/env perl

use strict;


my $dico  = $ARGV[0];
my $edges = $ARGV[1];

open (my $EDGES, '<', $edges) or die ("Cannot open the file $edges\nERROR:$!");
open (my $DICO , '<', $dico ) or die ("Cannot open the file $dico\nERROR:$!");


my $oid2Cluster = {};
my $ranks = ['species', 'genus', 'family', 'order', 'class', 'phylum'];


while (my $l = <$DICO>) {
    chomp $l;
    my ($clusterId, $oid) = split(/\t/,$l);
    if (defined $clusterId && $clusterId ne '' ) {
      $oid2Cluster->{$oid} = $clusterId;
      my $out = $clusterId.'-nodes.tab';
      open (my $CLUSTER, '>>', $out) or die ("Cannot open the file $out\nERROR:$!");
      print $CLUSTER $l,"\n";
      close $CLUSTER;
    }
}

while (my $l = <$EDGES>) {
    chomp $l;
    my ($oid1, $oid2, $distance) = split(/\t/,$l);
    my $clusterId1 = $oid2Cluster->{$oid1};
    my $clusterId2 = $oid2Cluster->{$oid2};
    ## in the same cluster
    if ($clusterId1 eq $clusterId2) {
      #print STDERR "$clusterId1 - $clusterId2\n";
      my $outFile = $clusterId2.'-edges.tab';
      open (my $CLU, '>>', $outFile) or die ("Cannot open the file $outFile\nERROR:$!");
      print $CLU $l,"\n";
      close $CLU;
    }
}

