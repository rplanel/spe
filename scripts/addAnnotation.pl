#!/usr/bin/env perl

use strict;
use Data::Dumper;

my $annotations = $ARGV[0];
my $silix       = $ARGV[1];


open (my $ANNO, '<', $annotations) or die ("Cannot open the file $annotations\nERROR:$!");

my $ranks = ['species', 'genus', 'family', 'order', 'class', 'phylum'];
my $annotationsDico = {};
while (my $l = <$ANNO>) {
    chomp $l;
    my ($oid, $strain, $name, $rank_name, $rank, $taxid) = split(/\t/,$l);
    $annotationsDico->{$oid}->{'oid_name'}  = $name;
    $annotationsDico->{$oid}->{'strain'}    = $strain;
    $annotationsDico->{$oid}->{$rank} = {
        'taxid'     => $taxid,
        'rank_name' => $rank_name,
    };
}

#print STDERR Dumper $annotationsDico;

open (my $SILIX, '<', $silix) or die ("Cannot open the file $silix\nERROR:$!");

while (my $l = <$SILIX>) {
    chomp $l;
    my ($fam, $raw_id) = split(/\t+/,$l);
    my $id = [split(/\./,$raw_id)]->[0];
    my $annoObj = $annotationsDico->{$id};
    my $anno = $annotationsDico->{$id}->{'oid_name'}." ".$annotationsDico->{$id}->{'strain'}."\t";
    foreach my $rank (@$ranks) {
	if (defined $annoObj->{$rank}) {
	    $anno .= $annoObj->{$rank}->{taxid}."\t";
	    $anno .= $annoObj->{$rank}->{rank_name}."\t";
        
      }
      else {
        $anno .= "\t\t";
      }
    }
    chop $anno;
    print $l,"\t",$anno,"\n";
}
