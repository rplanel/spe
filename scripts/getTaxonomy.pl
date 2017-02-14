#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Bio::DB::Taxonomy;
use Bio::DB::SoapEUtilities;


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
  }
  else {
    
    # print STDERR Dumper $taxa;
    if ($taxa) {
      my $oid = $taxa->id;
      my $name = $taxa->scientific_name;
      my $strain = '';
      while (my $taxa_ancestor = $taxa->ancestor()) {
	print_taxa($taxa_ancestor, $hash_ranks, $oid, $strain, $name);
	$taxa = $taxa_ancestor;
      }
    }
    else {
      print STDERR $taxid,"\n";
      # my $fac = Bio::DB::SoapEUtilities->new();
      # my $docs = $fac
      # 	->esummary(-db => 'taxonomy',
      # 		   -id => $taxid )
      # 	->run(-auto_adapt=>1);
      # # iterate over docsums
      # while (my $d = $docs->next_docsum) {
      # 	my @available_items = $d->ittaxonoem_names;
      # 	# any available item can be called as an accessor
      # 	# from the docsum object...watch your case...
      # 	print STDERR Dumper $d;
      # 	my $sci_name = $d->ScientificName;
      # 	my $taxid = $d->TaxId;
      # }
      $missing_taxids++;
      print STDERR "Missing taxid ($missing_taxids) = $taxid\n";
    }
  }
}



sub print_taxa {
    my ($taxa, $hash, $oid, $strain, $name) = @_;
    if (exists $hash->{$taxa->rank}) {
      print "$oid\t$strain\t$name\t",$taxa->scientific_name,"\t",$taxa->rank,"\t",$taxa->id,"\n";
    }

}

##print STDERR Dumper $human;
