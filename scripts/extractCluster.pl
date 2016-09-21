#!/usr/bin/env perl

use strict;

my $silix  = $ARGV[0];

open (my $SILIX, '<', $silix) or die ("Cannot open the file $silix\nERROR:$!");

while (my $l = <$SILIX>) {
    chomp $l;
    my ($clusterId, $anno) = split(/\t+/,$l, 2);
    my $out = $clusterId.'.tab';
    open (my $CLUSTER, '>>', $out) or die ("Cannot open the file $out\nERROR:$!");
    print $CLUSTER $anno,"\n";
}
