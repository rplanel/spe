#!/usr/bin/env perl

use strict;


my $annotations = $ARGV[0];
my $silix       = $ARGV[1];


open (my $ANNO, '<', $annotations) or die ("Cannot open the file $annotations\nERROR:$!");


my $annotationsDico = {};
while (my $l = <$ANNO>) {
    chomp $l;
    my ($oid, $anno) = split(/\t+/,$l,2);
    $annotationsDico->{$oid} = $anno;
}

open (my $SILIX, '<', $silix) or die ("Cannot open the file $silix\nERROR:$!");

while (my $l = <$SILIX>) {
    chomp $l;
    my ($fam, $id) = split(/\t+/,$l);
    print $l,"\t",$annotationsDico->{$id},"\n";
}
