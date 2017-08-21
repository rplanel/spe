#!/usr/bin/env python

import argparse
import sys
import os.path

parser = argparse.ArgumentParser()
parser.add_argument(
    "-e", "--edges",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the distances between each genomes (on distance per-line)"
)

# parser.add_argument(
#     "-o", "--output",
#     # nargs='?',
#     # type = argparse.FileType('w'),
#     help = "File that contains the distances between each genomes (on distance per-line)"
# )

args = parser.parse_args()
basename = os.path.splitext(os.path.basename(args.edges.name))[0]


outputDico = basename + '-dico.tsv'
outputEdges= basename + '-customid.tsv'

dic_out   = open(outputDico, 'w')
edges_out = open(outputEdges, 'w')


old_to_new_id = dict()

def set_id_to_node(node_id, dic):
    if node_id not in dic:
        dic[node_id] = str(len(dic))
    return dic[node_id]

args.edges.readline()
for line in args.edges:
    line_tr   = line.strip()
    columns   = line_tr.split("\t")
    columns[0] = set_id_to_node(columns[0],old_to_new_id)
    columns[1] = set_id_to_node(columns[1],old_to_new_id)
    edges_out.write("\t".join(columns)+"\n")
    

for k,v in old_to_new_id.items():
    dic_out.write(k + "\t" + v + "\n")
