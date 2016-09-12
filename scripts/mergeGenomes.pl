#!/usr/bin/env perl

use strict;


my $genomes = $ARGV[0];
my $output  = $ARGV[1];
my $currentId = '';


open (my $GENOMES, '<', $genomes) or die ("Cannot open the file $genomes\nERROR:$!");
open (my $OUT    , '>', $output ) or die ("Cannot open the file $output\nERROR:$!");

while (my $l = <$GENOMES>) {
    chomp $l;
    if ($l =~ /^>/) {
	my $id = getId($l);
	if ($id eq $currentId) {
	    next;
	}
	else {
	    $currentId = $id;
	    print $OUT $l,"\n";
	}
    }
    else {
	print $OUT $l,"\n";
    }
}
sub getId {
    my ($line) = @_;
    my ($id) = split(/_/,$line);
    $id =~ s/>//g;
    return $id;
}
