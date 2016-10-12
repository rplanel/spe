#!/usr/bin/env perl

use strict;
use Data::Dumper;

my $edges = $ARGV[0];



open (my $EDGES, '<', $edges) or die ("Cannot open the file $edges\nERROR:$!");

my $matrices = {};
my $memberToMatrix = {};
my $currentMatrix;
my $currentColumn;
my $bufColumnMatrix;
while (my $l = <$EDGES>) {
  chomp $l;
  my ($oid1, $oid2, $distance) = split(/\t+/,$l,3);

  if (!defined $currentColumn) {
    $currentColumn = $oid2;
    $bufColumnMatrix = [];
    $memberToMatrix->{$oid2} = $oid2;
    $matrices->{$oid2} = [];
    $currentMatrix = $oid2;
  }
  else {
    ## the first column so record all the member of the same matrix
    if ($currentMatrix == $oid2) {
      $memberToMatrix->{$oid1} = $currentColumn;
    }
    else {
      if (!exists $memberToMatrix->{$oid2}) { ##
	$memberToMatrix->{$oid2} = $oid2;
	$matrices->{$oid2} = [];
      }
      if ($currentColumn != $oid2) {
	writeColumnMatrix($currentMatrix, $matrices, $bufColumnMatrix);
	$bufColumnMatrix = [];
      }
      $currentMatrix = $memberToMatrix->{$oid1};
      $currentColumn = $oid2;
    }
  }
  push(@$bufColumnMatrix,$distance);
}

writeColumnMatrix($currentMatrix, $matrices, $bufColumnMatrix);
# print STDERR Dumper $matrices;
# print STDERR Dumper $memberToMatrix;

sub writeColumnMatrix {
    my ($currentMatrix, $matrices, $columnMatrix) = @_;
    push(@{$matrices->{$currentMatrix}},$columnMatrix);
}
