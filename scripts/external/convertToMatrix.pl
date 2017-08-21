#!/usr/bin/env perl

use strict;
use Data::Dumper;
use JSON;

my $edges = $ARGV[0];
my $dico  = $ARGV[1];



open (my $EDGES, '<', $edges) or die ("Cannot open the file $edges\nERROR:$!");
open (my $DICO , '<', $dico ) or die ("Cannot open the file $dico\nERROR:$!");

my $matrices = {};
## $memberToMatrix = {};
my $oid2Cluster = {};
my $currentClusterId;
my $currentColumnName;
my $currentMatrix;
my $currentColumn;
my $bufColumnMatrix;



# Fill the dictionnary

while (my $l = <$DICO>) {
    chomp $l;
    my ($clusterId, $oid, $name) = split(/\t/,$l);
    $oid2Cluster->{$oid} = {
			    clusterId => $clusterId,
			    name      => $name,
			   };
}

while (my $l = <$EDGES>) {
  chomp $l;
  my ($oid1, $oid2, $distance) = split(/\t/,$l);

  if (!defined $currentColumn) {
    $currentColumn = $oid2;
    $bufColumnMatrix = [];
    $currentClusterId = $oid2Cluster->{$currentColumn}->{clusterId};
    $matrices->{$currentClusterId} =
      {
       matrix => [],
       taxa   => [],
      };
    $currentMatrix = $matrices->{$currentClusterId};
    $currentColumnName = $currentClusterId = $oid2Cluster->{$currentColumn}->{name};
  }
  else {
    ## New column
    if ($currentColumn != $oid2) {
      ## write the previous column

      writeColumnMatrix($currentMatrix, $bufColumnMatrix, $currentColumnName);
      ## Check if the matrix is complete.
      my $matrix  = $currentMatrix->{matrix};
      my $columnL = scalar(@{$matrix->[0]});
      my $rowL    = scalar(@$matrix);
      #      print STDERR "$columnL == $rowL\n" if ($columnL > 3);
      if ($columnL == $rowL) {
	print STDERR $currentClusterId,"\n";
	print STDERR "$columnL == $rowL\n";
	writeMatrix($currentMatrix, $currentClusterId);
	$matrices = {};
      }
      ## Update the current Matrix
      $currentClusterId  = $oid2Cluster->{$oid2}->{clusterId};
      $currentColumnName = $oid2Cluster->{$oid2}->{name};

      ## Create the matrix entry if needed
      if (!exists $matrices->{$currentClusterId}) {
	$matrices->{$currentClusterId} = {
					  matrix => [],
					  taxa   => [],
					 };
      }
      $currentMatrix  = $matrices->{$currentClusterId};
      $bufColumnMatrix = [];
    }
    $currentColumn = $oid2;
  }
  push(@$bufColumnMatrix,$distance);
}

writeColumnMatrix($currentMatrix, $bufColumnMatrix, $currentColumnName);
writeMatrix($currentMatrix, $currentClusterId);

sub writeColumnMatrix {
  my ($matrix, $columnMatrix, $name) = @_;
  push(@{$matrix->{matrix}},$columnMatrix);
  push(@{$matrix->{taxa}  },{name => $name});
}

sub writeMatrix {
  my ($matrix, $clusterId) = @_;
  my $outName = $clusterId.'.txt';
  open (my $OUT, '>', $outName) or die ("Cannot open the file $outName\nERROR:$!");
  print $OUT 'var D = ',encode_json $matrix->{matrix},";\n";
  print $OUT 'var taxa = ',encode_json $matrix->{taxa},';';
  close $OUT;
}
