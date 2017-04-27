#!/usr/bin/env python

import argparse
import sys
import os.path

parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--clusters",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the distances between each genomes (on distance per-line)"
)


parser.add_argument(
    "-d", "--dico",
    help = "dico"
)


parser.add_argument(
    "-o", "--output",
    nargs='?',
    type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)

args = parser.parse_args()


dico    = open(args.dico, 'r')
id_dico = dict()

for line in dico:
    line_tr   = line.strip()
    columns   = line_tr.split("\t")
    id_dico[columns[1]] = columns[2]

args.clusters.readline()
for line in args.edges:
    line_tr    = line.strip()
    columns    = line_tr.split("\t")
    res = [ columns[1], id_dico[columns[0]] ]
    args.output.write("\t".join(columns))
