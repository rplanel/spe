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
my $ranks = ['strain', 'species', 'genus', 'family', 'order', 'class', 'phylum'];

while (my $l = <$CLUSTER>) {
  chomp $l;
  my @line = split(/\t+/,$l);
  
  my $clusterId      = $line[0];

  my $startParse = 1;
  
  foreach my $rank (@$ranks) {
      
      ## Group on the genus
      my $rankVal = $line[$startParse+1];
      my $taxid   = $line[$startParse];
      if ($taxid == 955) {
	  print STDERR $rank,"\t",$l,"\n";
      }
      $taxid2name->{$rank}->{$taxid} = $rankVal;
      
      next if (scalar @line < 1);
      
      ## calculate cluster stats
      $cluster->{$rank}->{$clusterId}->{stat}->{$taxid}++;
      $cluster->{$rank}->{$clusterId}->{total}++;
      
      
      
      ## Calculate rank stats
      $rankStat->{$rank}->{$taxid}->{total}++;
      $rankStat->{$rank}->{$taxid}->{stat}->{$clusterId}++;
      $startParse += 2;
  }
}



## transform cluster stat to json
my $clusterStatToJson = {};

foreach my $rank (@$ranks) {
    $clusterStatToJson->{$rank} = [];
    while ( my ($k, $v) = each %{$cluster->{$rank}} ) {
        ## for each cluster
        my $clusterStat = {
            name => $k,
            id   => $k,
            data => [],
        };
                
        my $tot = $v->{total};
        while (my ($taxid,$count) = each %{$v->{stat}}) {
            push(
                @{$clusterStat->{'data'}}, {
                    count => $count,
                    name  => $taxid2name->{$rank}->{$taxid},
                    id    => $taxid
                });
            print $CLUSTAT $k,"\t",$tot,"\t",$taxid,"\t",$taxid2name->{$rank}->{$taxid},"\t",$count,"\n";
        }
        push(@{$clusterStatToJson->{$rank}},$clusterStat);
    }
}
print $CLUSTATJ encode_json $clusterStatToJson;



## Transform rank stat to Json
my $rankStatToJson = {};
foreach my $rank (@$ranks) {  
    $rankStatToJson->{$rank} = [];
    while ( my ($k, $v) = each %{$rankStat->{$rank}} ) {
    
        my $rankStat = {
            name => $taxid2name->{$rank}->{$k},
            id   => $k,
            data => [],
        };
        my $tot = $v->{total};
        while (my ($clusterId,$count) = each %{$v->{stat}}) {
            push(
                @{$rankStat->{data}}, {
                    count => $count,
                    name  => $clusterId,
                    id    => $clusterId
                });
            print $RANKSTAT $k,"\t",$taxid2name->{$rank}->{$k},"\t",$tot,"\t",$clusterId,"\t",$count,"\n";
        }
        push(@{$rankStatToJson->{$rank}},$rankStat);
    }
}
print $RANKSTATJ encode_json $rankStatToJson;
