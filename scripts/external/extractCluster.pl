#!/usr/bin/env perl

use strict;
use Data::Dumper;
use PerlIO::gzip;

my $dico  = $ARGV[0];
my $edges = $ARGV[1];
my $distance_threshold = $ARGV[2];
my $base_name = $ARGV[3] || 'graph';


open (my $EDGES, '<:gzip', $edges) or die ("Cannot open the file $edges\nERROR:$!");
open (my $DICO , '<', $dico ) or die ("Cannot open the file $dico\nERROR:$!");

my $oid2Cluster = {};
my $cluster_fh  = {};	 # Store the filehandle for performance issue.
my $ranks = ['species', 'genus', 'family', 'order', 'class', 'phylum'];

while (my $l = <$DICO>) {
  chomp $l;
  my ($clusterId, $oid) = split(/\t/,$l);
  if (defined $clusterId && $clusterId ne '' ) {
    $oid2Cluster->{$oid} = $clusterId;
    ## open filehandle if needed
    if ( !exists $cluster_fh->{$clusterId}) {
      my $node_out   = $base_name.'-'.$clusterId.'-nodes.tab';
      my $edge_out   = $base_name.'-'.$clusterId.'-edges.tab';
      #my $f_edge_out = $base_name.'-'.$clusterId.'-edges-filter.tab';
      open (my $NODE , '>', $node_out  ) or die ("Cannot open the file $node_out\nERROR:$!");
      open (my $EDGE , '>', $edge_out  ) or die ("Cannot open the file $edge_out\nERROR:$!");
      #open (my $FEDGE, '>', $f_edge_out) or die ("Cannot open the file $edge_out\nERROR:$!");
      $cluster_fh->{$clusterId}->{node}  = $NODE;
      $cluster_fh->{$clusterId}->{edge}  = $EDGE;
      #$cluster_fh->{$clusterId}->{fedge} = $FEDGE;
    }
    my $OUT = $cluster_fh->{$clusterId}->{node};
    print $OUT $l,"\n";
  }
}


my $countLine = 0;

while (my $l = <$EDGES>) {
  $countLine++;
  # if ($countLine % 1000 == 0) {
  #   print STDERR '# ', $countLine,"\n";
  # }
  chomp $l;

  my ($oid1, $oid2, $distance) = split(/\t+/,$l);
  my $clusterId1 = $oid2Cluster->{$oid1};
  my $clusterId2 = $oid2Cluster->{$oid2};
  ## in the same cluster
  if ($clusterId1 eq $clusterId2) {
    if ( exists $cluster_fh->{$clusterId2} ) {
      my $OUT = $cluster_fh->{$clusterId2}->{edge};
      print $OUT $l,"\n";
      # if ($distance <= $distance_threshold) {
      # 	  my $FOUT = $cluster_fh->{$clusterId2}->{fedge};
      # 	  print $FOUT $l,"\n";
      # }
    } else {
      print STDERR "No filehandle for at line $countLine: $clusterId2 - $clusterId1\n$l\n";
      exit 1;
    }
  }
}

