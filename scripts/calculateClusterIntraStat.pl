#!/usr/bin/env perl

use strict;
use File::Basename;
use Data::Dumper;
use JSON;

my $cluster  = $ARGV[0];
my $baseName = $ARGV[1];

my $clusterStatOut = $baseName.'-cluster.tab';
my $jsonClusterStatOut = $baseName.'-cluster.json';

my $rankStatOut     = $baseName.'-rank.tab';
my $jsonRankStatOut = $baseName.'-rank.json';

open (my $CLUSTER, '<', $cluster) or die ("Cannot open the file $cluster\nERROR:$!");

open (my $CLUSTAT , '>', $clusterStatOut    ) or die ("Cannot open the file $clusterStatOut\nERROR:$!");
open (my $CLUSTATJ, '>', $jsonClusterStatOut) or die ("Cannot open the file $jsonClusterStatOut\nERROR:$!");

open (my $RANKSTAT , '>', $rankStatOut)     or die ("Cannot open the file $rankStatOut\nERROR:$!");
open (my $RANKSTATJ, '>', $jsonRankStatOut) or die ("Cannot open the file $jsonRankStatOut\nERROR:$!");



my $cluster = {};
my $currentClusterId;
my $totalPerCluster;
my $rankStat = {};
my $taxid2name = {};

while (my $l = <$CLUSTER>) {
  chomp $l;
  my @line = split(/\t+/,$l);
  my $id      = $line[0];
  my $rankVal = $line[4];
  my $taxid   = $line[6];

  $taxid2name->{$taxid} = $rankVal;
  
  next if (scalar @line < 1);
  
  ## calculate cluster stats
  $cluster->{$id}->{stat}->{$taxid}++;
  $cluster->{$id}->{total}++;
  

  
  ## Calculate rank stats
  $rankStat->{$taxid}->{total}++;
  $rankStat->{$taxid}->{stat}->{$id}++;
}


my $clusterStatToJson = [];
while ( my ($k, $v) = each %$cluster ) {
    ## for each cluster
    my $clusterStat = {
	name => "$k",
	data => [],
    };
    my $tot = $v->{total};
    while (my ($taxid,$count) = each %{$v->{stat}}) {
	push(
	    @{$clusterStat->{data}}, {
		count => $count,
		name  => $taxid2name->{$taxid},
		taxid => $taxid
	    });
    	print $CLUSTAT $k,"\t",$tot,"\t",$taxid,"\t",$taxid2name->{$taxid},"\t",$count,"\n";
    }
    push(@$clusterStatToJson,$clusterStat);
}
print $CLUSTATJ encode_json $clusterStatToJson;

my $rankStatToJson = [];
while ( my ($k, $v) = each %$rankStat ) {
    my $rankStat = {
	name  => $taxid2name->{$k},
	taxid =>  $k,
	data => []
    };
    my $tot = $v->{total};
    while (my ($clusterId,$count) = each %{$v->{stat}}) {
	push(
	    @{$rankStat->{data}}, {
		count => $count,
		name  => $clusterId,
	    });
	print $RANKSTAT $k,"\t",$taxid2name->{$k},"\t",$tot,"\t",$clusterId,"\t",$count,"\n";
    }
    push(@$rankStatToJson,$rankStat);
}
print $RANKSTATJ encode_json $rankStatToJson;
