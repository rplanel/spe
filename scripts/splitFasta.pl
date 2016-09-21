#!/usr/bin/env perl

use strict;
use File::Basename;

my $genomes = $ARGV[0];
my $outdir  = $ARGV[1];

open (my $GENOMES, '<', $genomes) or die ("Cannot open the file $genomes\nERROR:$!");
mkdir $outdir;

#Remove trailing /
$outdir =~ s/\/$//g;
my $OUT;

while (my $l = <$GENOMES>) {
    chomp $l;
    if ($l =~ /^>/) {

	
	close $OUT if defined $OUT;
	my $id = getId($l);
	open ($OUT, '>',  $outdir.'/'.$id.'.fasta') or die ("Cannot open the file \nERROR:$!");
	print $OUT $l,"\n";
    }
    else {
	print $OUT $l,"\n";
    }
}

sub getId {
    my ($line) = @_;
    my ($id) = split(/\s+/,$line);
    $id =~ s/>//g;
    return $id;
}



    
