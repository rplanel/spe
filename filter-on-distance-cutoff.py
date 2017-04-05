#!/usr/bin/python env


import argparse
import sys
import os.path


parser = argparse.ArgumentParser()

parser.add_argument(
    "-e", "--edges",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "edges file return by mash"
)

parser.add_argument(
    "-d", "--distance",
    type=float,
    required=True,
    help = "edges file return by mash"
)


args = parser.parse_args()


for line in args.edges:
    line_tr  = line.strip()
    columns  = line_tr.split("\t")
    node1    = columns[0]
    node2    = columns[1]
    distance = float(columns[2])

    if distance <= 0.16:
        print(line_tr)
