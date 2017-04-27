#!/usr/bin/env python

import argparse
import sys
import os.path
import community
import networkx as nx

parser = argparse.ArgumentParser()
parser.add_argument(
    "-e", "--edges",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the distances between each genomes (on distance per-line)"
)

parser.add_argument(
    "-o", "--output",
    nargs='?',
    type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)

parser.add_argument(
    '-w', '--weight',
    help='Take into account the link weight',
    action='store_true'
)

args = parser.parse_args()
G = nx.Graph()


def add_edge(G, columns):
    G.add_edge(columns[0], columns[1])

def add_weighted_edge(G, columns):
    G.add_edge(columns[0], columns[1], weight=float(columns[2]))
    


custom_add_edge =  add_weighted_edge if args.weight else add_edge;


for line in args.edges:
    line_tr   = line.strip()
    columns   = line_tr.split("\t")
    #db_ids    = [columns[0], columns[1]]
    custom_add_edge(G,columns)
    #G.add_edge(columns[0], columns[1])
    

#first compute the best partition
# partition = community.best_partition(G)

partition = community.best_partition(G, weight='weight')



for k, v in partition.items():
    args.output.write(str(v) + "\t" + k + "\n")
    
