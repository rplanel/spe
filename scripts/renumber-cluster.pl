#!/usr/bin/env perl

use strict;
use Getopt::Long;

my $vector_file;
my $out = 'renumbered-vectors.tsv';

GetOptions ( "vectors=s" => \$vector_file) or die("Error in command line arguments\n");

open (my $VECTORS, '<', $vector_file) or die("Cannot open the file $vector_file");


my $hash_col_1 = {};
my $col_1_id = 1;

my $hash_col_2 = {};
my $col_2_id = 1;

while (my $l = <$VECTORS>) {
  chomp $l;
  my ($col_1, $col_2) = split(/\s+/,$l);
  my $col_1_new = get_new_number($col_1, $hash_col_1, \$col_1_id);
  my $col_2_new = get_new_number($col_2, $hash_col_2, \$col_2_id);
  print $col_1_new,' ',$col_2_new,"\n";
}

sub get_new_number {
  my ($number, $hash, $col_id) = @_;

  if (exists $hash->{$number}) {
    return $hash->{$number};
  }
  else {
    return $hash->{$number} = $$col_id++;
  }
  
  
}
