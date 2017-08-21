#!/usr/bin/env python

import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--count",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the distances between each genomes (on distance per-line)"
)

# parser.add_argument(
#     "-o", "--output",
#     nargs='?',
#     type = argparse.FileType('w'),
#     help = "File that contains the distances between each genomes (on distance per-line)"
# )

# parser.add_argument(
#     '-w', '--weight',
#     help='Take into account the link weight',
#     action='store_true'
# )

args = parser.parse_args()

def getKey(item):
    return item[0]


dico_per_rank = dict()
args.count.readline()
for line in args.count:
    line_tr = line.strip()
    columns = line_tr.split('\t')
    rank_id = columns[3]
    if rank_id not in dico_per_rank:
        dico_per_rank[rank_id] = [0, None, None]

    count = dico_per_rank[rank_id][0] + int(columns[0])
    dico_per_rank[rank_id] = [count, rank_id, columns[4]]




sorted_line = sorted(dico_per_rank.values(), key=getKey,reverse=True)
    
for line in sorted_line:
    line_str = [str(l) for l in line]
    print('\t'.join(line_str))
