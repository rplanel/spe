#!/usr/bin/python env


import argparse
import sys
import os.path
import fileinput
from reporter import Reporter
from bronker_bosch1 import bronker_bosch1
from bronker_bosch2 import bronker_bosch2
from bronker_bosch3 import bronker_bosch3

parser = argparse.ArgumentParser()
parser.add_argument(
    "-e", "--edges",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "edges file return by mash"
)


args = parser.parse_args()

def merge(lsts):
    """Niklas B."""
    sets = [set(lst) for lst in lsts if lst]
    merged = 1
    while merged:
        merged = 0
        results = []
        while sets:
            common, rest = sets[0], sets[1:]
            sets = []
            for x in rest:
                if x.isdisjoint(common):
                    sets.append(x)
                else:
                    merged = 1
                    common |= x
            results.append(common)
        sets = results
    return sets


node_to_id = dict()

for line in args.edges:
    line_tr = line.strip()
    columns = line_tr.split("\t")
    
    node1 = columns[0]
    node2 = columns[1]

    if node1 != node2:
        #current_len   = len(neighbors)
        identifiant   = node1+node2
        r_identifiant = node2+node1
        if node1 not in node_to_id:
            node_to_id[node1] = []

        node_to_id[node1].append(node2)

print(len(node_to_id))
        
#NEIGHBORS = list(node_to_id.values())
#NEIGHBORS.insert(0,[])
#NODES = set(range(1, len(NEIGHBORS)))


NEIGHBORS = node_to_id
NODES = list(node_to_id.keys())
#MIN_SIZE = 3
# NEIGHBORS = [
#     [], # I want to start index from 1 instead of 0
#     [2, 3, 4],
#     [1, 3, 4, 5],
#     [1, 2, 4, 5],
#     [1, 2, 3],
#     [2, 3, 6, 7],
#     [5, 7],
#     [5, 6],
# ]
# NODES = set(range(1, len(NEIGHBORS)))

# NEIGHBORS = [
#     [], # I want to start index from 1 instead of 0
#     [2, 5],
#     [1, 3, 5],
#     [2, 4],
#     [3, 5, 6],
#     [1, 2, 4],
#     [4],
    
# ]
# NODES = set(range(1, len(NEIGHBORS)))


if __name__ == '__main__':
    funcs = [
        ##bronker_bosch1,
        bronker_bosch2,
        #bronker_bosch3
    ]

    for func in funcs:
        #print('## %s' % func.func_doc)
        report = Reporter('## %s' % func.func_doc)
        #print("start algo: "+ func.func_doc)
        func([], set(NODES), set(), report, NEIGHBORS)
        #report.print_report()
        #array_of_set = [ set(clique) for clique in report.cliques ]
        #print("start merge")
        cliques_and_cliques_grp = merge(report.cliques)
        #print(len(cliques_and_cliques_grp))
        for i, nodes in enumerate(cliques_and_cliques_grp):
            for node in nodes:
                print(str(i) + "\t" + str(node))
    #print(report.cliques)
    

# report = Reporter('## %s' % bronker_bosch1.func_doc)
# bronker_bosch1([], set(NODES), set(), report)

# report.print_report()


# print(array_of_set[0])
# print(array_of_set[1])
# print(array_of_set[0].intersection(array_of_set[1]))
