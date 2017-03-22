#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Bio::DB::Taxonomy;
use Bio::DB::EUtilities;


my $root_dir = '/env/cns/home/rplanel/my_proj/test/mash/data/taxonomy';

my $db = Bio::DB::Taxonomy->new(
				-source    => 'flatfile',
				-directory => "$root_dir/index",
				-nodesfile => "$root_dir/nodes.dmp",
				-namesfile => "$root_dir/names.dmp",
			       );



my $list_taxids = $ARGV[0];
my $ranks = ['species', 'genus', 'family', 'order', 'class', 'phylum'];
my $hash_ranks = {
		  'species' => 0, 
		  'genus' => 0, 
		  'family' => 0, 
		  'order' => 0, 
		  'class' => 0, 
		  'phylum' => 0
		 };

my $missing_taxids = 0;
open(my $TAXIDS, '<', $list_taxids) or die("Cannot open file : $list_taxids.\nERROR: $!");


while ( my $taxid = <$TAXIDS> ) {
  chomp $taxid;
  my $taxa;
  eval {
    $taxa = $db->get_taxon(-taxonid => $taxid);
  };
  if ($@ ) {
    print STDERR "do not find taxid = $taxid\n";
  } else {
    # print STDERR Dumper $taxa;
    if ($taxa) {
      my $oid = $taxid;
      my $name = $taxa->scientific_name;
      my $strain = '';
      print_taxa($taxa, $hash_ranks, $oid, $strain, $name);
    } else {
      ## 1054400
      $db = Bio::DB::Taxonomy->new(-source => 'entrez');
      $taxa = $db->get_taxon(-taxonid => $taxid);
      if ($taxa) {
	my $oid = $taxid;
	my $name = $taxa->scientific_name;
	my $strain = '';
	print_taxa($taxa, $hash_ranks, $oid, $strain, $name);
      }
    }
  }
}


sub print_taxa {
  my ($taxa, $hash, $oid, $strain, $name) = @_;
  while ($taxa) {
    if (exists $hash->{$taxa->rank}) {
      print "$oid\t$strain\t$name\t",$taxa->scientific_name,"\t",$taxa->rank,"\t",$taxa->id,"\n";
    }
    $taxa = $taxa->ancestor;
  }
}

  ##print STDERR Dumper $human;
