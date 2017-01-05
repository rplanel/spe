#!/usr/bin/env perl

use strict;
use Data::Dumper;
use File::Basename;

my $clustersFile  = $ARGV[0];


open (my $CLU, '<', $clustersFile) or die ("Cannot open the file $clustersFile\nERROR:$!");
open (my $OUT, '>', $clustersFile.'-randIndex.csv') or die ("Cannot open the file rand output \nERROR:$!");

my($filename, $dir, $suffix) = fileparse($clustersFile);


my $outputs = [
	       {index => 3 ,name => 'species'},
	       {index => 5 ,name => 'genus'},
	       {index => 7 ,name => 'family'},
	       {index => 9 ,name => 'order'},
	       {index => 11,name => 'class'},
	       {index => 13,name => 'phylum'},
	      ];


## open output filehandler

foreach my $out (@$outputs) {
  open($out->{fh}, '>', $dir.'vector-rand-index-'.$out->{name}.'.csv') or die ("Cannot open the file\nERROR:$!");
}


LINE : while (my $l = <$CLU>) {
  chomp $l;
  next if $l =~ /^\s+$/;
  my @taxonomy = split(/\t/,$l);
  my @res;
  # print STDERR Dumper \@taxonomy;
  (my $clusterId = $taxonomy[0]) =~ s/CL//g;
  foreach my $out (@$outputs) {
    my $FHO = $out->{fh};
    my $taxid = $taxonomy[$out->{index}];
    if ($taxid eq '') {
      next LINE;
    }
    else {
      print  $FHO $clusterId,"\t",$taxid,"\n";
    }
  }
  
  #    print STDERR $clusterId,"\n";
}




sub getTaxid {
  my ($start, $taxonomy) = @_;
  my $taxid;
  my $taxoL = scalar @$taxonomy;
 TAXO: for (my $i=$start; $i < $taxoL; $i=$i+2) {
    $taxid = $taxonomy->[$i];
    if ($taxid =~ /\d+/) {
      last TAXO;
    }
  }
  return (!$taxid) ? undef : $taxid;
}
