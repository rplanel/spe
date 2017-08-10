#!/usr/bin/env python

import argparse
import sys
import os.path

parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--clustering",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the distances between each genomes (on distance per-line)"
)

parser.add_argument(
    "-d", "--dico",
    help = ""
)

parser.add_argument(
    "-o", "--output",
    nargs='?',
    type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)

args = parser.parse_args()



new_to_old = dict()


dico_fh = open(args.dico, 'r')
for line in dico_fh:
    line_tr = line.strip()
    columns = line_tr.split("\t")
    new_to_old[columns[0]] = columns[1]

for line in args.clustering:
    if not line.startswith("#"):
        line_tr = line.strip()
        columns = line_tr.split(" ")
        args.output.write(str(columns[1]) + '\t' + str(new_to_old[columns[0]]) + '\n')
        
