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

parser.add_argument(
    "-o", "--output",
    nargs='?',
    type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)

args = parser.parse_args()


countNodes = 0
countLinks = 0
nodesDico = dict()
linksSet = set()

for line in args.edges:
    line_tr = line.strip()
    columns = line_tr.split("\t")
    nodeId1 = columns[0]
    nodeId2 = columns[1]
    nodes   = [nodeId1, nodeId2]
    linkId  = str(nodeId1)+str(nodeId2)
    nodeLine = []
    # add nodes
    for nodeId in nodes:
        if nodeId1 not in nodesDico:
            nodesDico[nodeId] = countNodes
            countNodes += 1
        nodeLine.append(str(nodesDico[nodeId]))
    ## add the distance. 1-distance to make it like a weight.
    nodeLine.append(str(1-float(columns[2])))
    if linkId not in linksSet:
        linksSet.add(linkId)
        args.output.write("\t".join(nodeLine)+"\n")


dicoFile = open('new-to-original-id.tsv','w')


for k, v in nodesDico.items():
    dicoFile.write(str(v)+"\t"+str(k)+"\n")
