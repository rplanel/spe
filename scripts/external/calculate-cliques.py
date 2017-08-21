#!/usr/bin/env python

import argparse
import sys
import os.path
import os.path
import fileinput
import gzip

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
    # nargs='?',
    # type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)

# parser.add_argument(
#     "-ci", "--cluster_id",
#     help = "Cluster's identifier."
# )


args = parser.parse_args()

#os.path.basename("")


basename = os.path.basename(args.edges.name).split('.')[0]
print(basename)
qc_node_id_output = basename + '-qc-node-id.txt'

output_tmp = open(qc_node_id_output, 'w')
old_to_new_id = dict()
count = 0
links_count = 0
links_set = set()
max_clique_group = set()

def merge(sets):
    """Niklas B."""
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

def che_merge(sets):
    """ChessMaster"""
    results = []
    upd, isd, pop = set.update, set.isdisjoint, sets.pop
    while sets:
        if not [upd(sets[0],pop(i)) for i in range(len(sets)-1,0,-1) if not isd(sets[0],sets[i])]:
            results.append(pop(0))
    return results


def set_id_to_node(node_id, dic):
    if node_id not in dic:
        dic[node_id] = str(len(dic))
    return dic[node_id]


# print("## Start read edges file")

# args.edges.readline()
# for line in args.edges:
#     line_tr   = line.strip()
#     columns   = line_tr.split("\t")
#     db_ids    = [columns[0], columns[1]]
#     new_edges = [ set_id_to_node(node, old_to_new_id) for node in db_ids];

#     ## qc needs to have v1,v2 and v2,v1 but not v1,v1.
#     ## I force the output to look like that and I record the links
#     if new_edges[0] != new_edges[1]:
#         link_id = ",".join(sorted(new_edges))
#         if link_id not in links_set:
#             links_set.add(link_id)
#             for link in [ ','.join(new_edges), ','.join(reversed(new_edges)) ]:
#                 output_tmp.write(link+"\n")

     
# output_tmp.close()
# print("## End read edges file")
# #output = open(args.output, 'w')

# lines_to_prepend = str(len(old_to_new_id)) + "\n" + str(len(links_set) * 2)
# f = fileinput.input(qc_node_id_output, inplace=True)
# for line in f:
#     line = line.strip()
#     if f.isfirstline():
#         print(lines_to_prepend.rstrip('\r\n') + '\n' + line)
#     else:
#         print(line)

# f.close()

# print("Start the max clique calculation")

# os.system('qc --input-file=' + qc_node_id_output + ' --algorithm=hybrid > qc-cliques.output')

# print("End the max clique calculation")

max_cliques = open('qc-cliques.output', 'r')


clique_sets = []
line_number = 0
for line in max_cliques:
    line_number += 1
    if line_number >= 3:
        if line_number == 3:
            print(line)
        line_tr = line.strip()
        columns = line_tr.split(" ")
        clique_sets.append(set(columns))


#print(clique_sets)
#clique_groups = merge(clique_sets)
print('## Start merge')
clique_groups = che_merge(clique_sets)
print("Nombre de clique group : " + str(len(clique_groups)))

# clique_file = open(args.output, 'w')

# new_to_old_id = {v: k for k, v in old_to_new_id.items()}

# for i, clique_group in enumerate(clique_groups):
#     for genome in clique_group:
#         clique_file.write(str(i)+"\t"+ new_to_old_id[genome]+"\n")

    #open(args.cluster_id+'-'+str(i))
    # for node in nodes:
    #     print(str(i) + "\t" + str(node))
        

#pickle.dump(progenome_to_id, open( "node-id-to-int.dict", "wb" ) )
