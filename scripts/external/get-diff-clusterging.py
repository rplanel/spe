#!/usr/bin/env python

import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--clustering",
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

cluster_to_node1 = dict()
cluster_to_node2 = dict()

node_to_cluster = dict()

id_node = 0

res_count = dict()

for line in args.clustering:
    line_tr = line.strip()
    columns = line_tr.split('\t')
    if columns[0] not in cluster_to_node1:
        cluster_to_node1[columns[0]] = set()
        
    if columns[1] not in cluster_to_node2:
        cluster_to_node2[columns[1]] = set()

    cluster_to_node1[columns[0]].add(id_node)
    cluster_to_node2[columns[1]].add(id_node)
    anno = columns[2:]
    node_to_cluster[id_node] = [columns[0], columns[1]] + anno
    id_node += 1
    
    # print(cluster_to_node1)
    # print(cluster_to_node2)

for clu_id1, clu1 in cluster_to_node1.items():
    smallest_diff = [1, None, None, set()]
    for clu_id2, clu2 in cluster_to_node2.items():
        # print('======new compare')
        # print(clu1)
        # print(clu2)
        union = clu1.union(clu2)
        # print('union')
        # print(union)
        if len(union) == 0:
            next
        else :
            difference = clu1.symmetric_difference(clu2)
            # print('diff')
            # print(difference)
            ratio = len(difference) / len(union)
            # print(ratio)
            if ratio < smallest_diff[0]:
                smallest_diff[0] = ratio
                smallest_diff[1] = clu_id1
                smallest_diff[2] = clu_id2
                smallest_diff[3] = difference

        
        res_count[clu_id1] = smallest_diff
    


# print(res_count)
summary = dict()
for clu_id, res in res_count.items():
    for node in res[3]:
        if node not in summary:
            summary[node] = [1, node] + node_to_cluster[node]
        else:
            count = summary[node][0] + 1
            summary[node][0] = count

print("\t".join(['count', 'node_id', 'clu_id_1','clus_id_2','rank_name']))
for summ in summary.values():

    line = [ str(it) for it in summ]
    print('\t'.join(line))
# for node_id in node_to_cluster.keys():
#     cluster_in_1 = node_to_cluster[node_id][0]
#     cluster_in_2 = node_to_cluster[node_id][1]
#     max_diff = 0
#     for diff_node in cluster_to_node1[cluster_in_1].difference(cluster_to_node2[cluster_in_2]):
#         if node_id not in res_count:
#             res_count[node_id] = [1,node_to_cluster[node_id][2]]
#         else:
#             res_count[node_id][0] += 1 
            


# res2 = sorted(res_count.values(), key=getKey,reverse=True)

# for res in res2:
#     print(res[1] + "\t" + str(res[0]))

