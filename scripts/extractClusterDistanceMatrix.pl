#!/usr/bin/env perl

use strict;
use Data::Dumper;
use JSON;

my $cluster  = $ARGV[0];
my $distance = $ARGV[1];

my $oid2Cluster = {};
my $ranks = ['species', 'genus', 'family', 'order', 'class_', 'phylum'];
my $currentColumnId;
my $column;
my $matrix = [];
my $taxo = [];
my $clusterId;
open (my $DIS  , '<', $distance) or die ("Cannot open the file $distance\nERROR:$!");
open (my $CLUS , '<', $cluster ) or die ("Cannot open the file $cluster\nERROR:$!" );



while (my $l = <$CLUS>) {
    chomp $l;
    my ($clusId, $oid, $name, $taxo) = split(/\t/,$l,4);
    $clusterId = $clusId;
    $oid2Cluster->{$oid} = {
			    name => $name,
			    id => $oid,
			    taxonomy => {
				'oid' => {
				    taxid => $oid,
				    name  => $name
				}
			    },
			   };
    
    my $taxoObj = $oid2Cluster->{$oid}->{taxonomy};
    my @taxo = split(/\t/,$taxo);
    my $ranksL = scalar(@$ranks);
    for (my $i = 0; $i < $ranksL; $i++) {
	my $rank = $ranks->[$i];
	my $taxoIndex = $i*2;
	$taxoObj->{$rank} = {
	    'taxid' => $taxo[$taxoIndex],
	    'name'  => $taxo[$taxoIndex+1],
	};
    }
}


while (my $l = <$DIS>) {
  chomp $l;
  my ($oid1, $oid2, $distance) = split(/\t/,$l);
  if (!defined $currentColumnId) {
    $currentColumnId = $oid2;
    $column = startColumn($taxo,$oid2Cluster,$currentColumnId);
  }
  else {
    # new column
    if ($currentColumnId != $oid2) {
      writeColumn($matrix,$column);
      $currentColumnId = $oid2;
      $column = startColumn($taxo,$oid2Cluster,$currentColumnId);
    }
  }
  push(@$column,$distance);
}
writeColumn($matrix,$column);

sub startColumn {
  my ($taxo,$dico,$id) = @_;
  push(@$taxo, $dico->{$id});
  return [];
}

sub writeColumn {
  my ($matrix,$column) = @_;
  push(@$matrix, $column);
}

## print la matrix.
my $matrixOut = $clusterId.'-distance-matrix.json';
my $taxaOut     = $clusterId.'-taxa.json';

open (my $MATRIX , '>', $matrixOut) or die ("Cannot open the file $matrixOut\nERROR:$!" );
open (my $TAXA   , '>', $taxaOut) or die ("Cannot open the file $taxaOut\nERROR:$!" );

print $MATRIX encode_json $matrix,"\n";
print $TAXA encode_json $taxo,"\n";
