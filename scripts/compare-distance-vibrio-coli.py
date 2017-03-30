#!/usr/bin/env python3

import sys
import re
from functools import reduce
from pprint import pprint

dico_annotation          = [
    {
        'name'      : 'vibrio',
        'collection': set(),
        'pattern'   : re.compile(r"7\t+\d+\.\w+\t+Vibrio"),
        'min': 0,
        'max': 0,
    },
    {
        'name'      : 'not_vibrio',
        'collection': set(),
        'pattern'   : re.compile(r"7\t+\d+\.\w+\t+[^Vibrio]"),
        'min': 0,
        'max': 0,
    },

    # {
    #     'name'      : 'escherichia_coli',
    #     'collection': set(),
    #     'pattern'   : re.compile(r"7\t+\d+\.\w+\t+Escherichia coli"),
    #     'min': 0,
    #     'max': 0,
    # },
    # {
    #     'name'      : 'klebsiella',
    #     'collection': set(),
    #     'pattern'   : re.compile(r"7\t+\d+\.\w+\t+.+Klebsiella"),
    #     'min': 0,
    #     'max': 0,
    # },

    # 'vibrio_other'       : {
    #     'collection': set()
    # },
];
dir_out = r'/home/rplanel/test/vibrio-coli'
taxo_patterns = []

annotations_file         = open(sys.argv[1], 'r')
distance_matrix_file     = open(sys.argv[2], 'r')
filtered_distance_matrix = open(dir_out+'/out.txt', 'w')
filtered_annotation      = open(dir_out+'/out-table.tsv', 'w')

#7       633.PRJNA243530 Yersinia pseudotuberculosis     633     Yersinia pseudotuberculosis     629     Yersinia        1903411 Yersiniaceae    91347   Enterobacterales        1236    Gammaproteobacteria     1224    Proteobacteria


filtered_distance_matrix.write("node1\tnode2\tdistance\tevalue\tscore\n")
filtered_annotation.write("node_id\tstrain_name\tspecies_taxid\tspecies\tgenus_taxid\tgenus\tfamily_taxid\tfamily\torder_taxid\torder\tclass_taxid\tclass\tphylum_taxid\tphylum\n")

for l in annotations_file:
    for value in dico_annotation:
        re_pattern = value['pattern']
        if re_pattern.match(l):
            list_line = l.split("\t")
            value['collection'].add(list_line[1])

filtered_annotation.close()

max = len(dico_annotation)
min = 0
combination = []
for i in range(max):
    for j in range(max):
        if i > j:
            combination.append(int(str(i)+str(j)))
        else:
            continue

## create links possibility
def create_edges(edges, num):
    separate_digit = list(map(int,str(num)))
    edges[num] = {
        'name': dico_annotation[separate_digit[0]]['name'] + "\t" + dico_annotation[separate_digit[1]]['name'],
        'max' : 0,
        'min' : 1,
        'strains': [],
        'links'  : []
    }
    return edges

edges = reduce(create_edges,combination, {})

# Compare the collections
for l in distance_matrix_file:
    list_line = l.split("\t")
    taxids = [
        list_line[0],#.split(".")[0],
        list_line[1]#.split(".")[0]
    ]
    res = ''
    for taxid in taxids:
        for i, anno in enumerate(dico_annotation):
            if taxid in anno['collection']:
                res += str(i)

    if len(res) == 2:
        set_res = { int(res), int(res[::-1]) }
        for combi in combination:
            if combi in set_res:
                distance = float(list_line[2])
                if distance < 0.16:
                    edges[combi]['links'].append({
                        'node1': list_line[0],
                        'node2': list_line[1],
                        'distance': distance
                    })
                    
                if distance < edges[combi]['min']:
                    edges[combi]['min'] = distance
                    edges[combi]['strains'] = [list_line[0],list_line[1]]
                    # print(edges)
                    # print("====================================")


print(edges)
for k, edge in edges.items():
    for line in edge['links']:
        print(line['node1'] + "\t" + line['node2'] + "\t" + str(line['distance']))
