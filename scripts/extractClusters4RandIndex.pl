
#!/usr/bin/env perl

use strict;
use Data::Dumper;
use File::Basename;

my $clustersFile  = $ARGV[0];
my $dico_taxo_correction_file = $ARGV[1];

open (my $CLU, '<', $clustersFile) or die ("Cannot open the file $clustersFile\nERROR:$!");
open (my $OUT, '>', $clustersFile.'-randIndex.csv') or die ("Cannot open the file rand output \nERROR:$!");

my $dico_taxo_correction = {};
if ($dico_taxo_correction_file) {
  open (my $DICO, '<', $dico_taxo_correction_file) or die ("Cannot open the file $dico_taxo_correction_file\nERROR:$!");
  while (my $l = <$DICO>) {
    chomp $l;
    my @columns = split(/\t/,$l);
    $dico_taxo_correction->{$columns[0]}->{$columns[1]} = $columns[2];
  }
}

my($filename, $dir, $suffix) = fileparse($clustersFile);


my $outputs = [
	       {
		index => 3 ,name => 'species'},
	       {
		index => 5 ,name => 'genus'},
	       {
		index => 7 ,name => 'family'},
	       {
		index => 9 ,name => 'order'},
	       {
		index => 11,name => 'class'},
	       {
		index => 13,name => 'phylum'},
	      ];


## open output filehandler

# foreach my $out (@$outputs) {
#   open($out->{fh}, '>', $dir.'vector-'.$out->{name}.'.csv') or die ("Cannot open the file\nERROR:$!");
# }


LINE : while (my $l = <$CLU>) {
  chomp $l;
  next if $l =~ /^\s+$/;
  my @taxonomy = split(/\t/,$l);
  my @res;
  # print STDERR Dumper \@taxonomy;
  (my $clusterId = $taxonomy[0]) =~ s/CL//g;
  foreach my $out (@$outputs) {
    my $taxid   = $taxonomy[$out->{index}];
    my $rank_name = $out->{name};
    if ($taxid eq '') {
      next LINE;
    } else {
      if (!exists $out->{fh}) {
	open($out->{fh}, '>', $dir.'vector-'.$rank_name.'.csv') or die ("Cannot open the file\nERROR:$!");
      }
      my $FHO = $out->{fh};
      my $taxname = $taxonomy[$out->{index}+1];
      my $strain_taxid =  $taxonomy[1];
      my $strain_name =  $taxonomy[2];
      if (exists $dico_taxo_correction->{$rank_name} && $dico_taxo_correction->{$rank_name}->{$taxid}) {
	$taxid = $dico_taxo_correction->{$rank_name}->{$taxid};
	print  $FHO $clusterId,"\t",$taxid,"\t",$taxname,"\t",$strain_name, "\t",$strain_taxid,"\n";
      }
      else {
	print  $FHO $clusterId,"\t",$taxid,"\t",$taxname,"\t",$strain_name, "\t",$strain_taxid,"\n";
      }
    }
  }
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
