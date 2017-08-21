#!/usr/bin/env python3

import sys
import re

##.*|Escherichia coli 2864350

dico_annotation          = set();
dir_out = r'/home/rplanel/test/vibrio-coli'
pattern_taxo             = re.compile(".*(\t+Vibrio|\t*Escherichia coli 2864350\t*).*")

annotations_file         = open(sys.argv[1], 'r')
distance_matrix_file     = open(sys.argv[2], 'r')
filtered_distance_matrix = open(dir_out+'/out.txt', 'w')
filtered_annotation      = open(dir_out+'/out-table.tsv', 'w')

#7       633.PRJNA243530 Yersinia pseudotuberculosis     633     Yersinia pseudotuberculosis     629     Yersinia        1903411 Yersiniaceae    91347   Enterobacterales        1236    Gammaproteobacteria     1224    Proteobacteria


filtered_distance_matrix.write("node1\tnode2\tdistance\tevalue\tscore\n")
filtered_annotation.write("node_id\tstrain_name\tspecies_taxid\tspecies\tgenus_taxid\tgenus\tfamily_taxid\tfamily\torder_taxid\torder\tclass_taxid\tclass\tphylum_taxid\tphylum\n")





for l in annotations_file:
    list_line = l.split("\t", 2)
    
    if pattern_taxo.match(list_line[2]):
        taxid = list_line[1]##.split(".")[0]
        # print(taxid)
        dico_annotation.add(taxid)
        ##print(list_line[2])
        filtered_annotation.write(taxid + "\t" + list_line[2])

filtered_annotation.close()
        
print("Filtered the distance matrix")
        
for l in distance_matrix_file:
    list_line = l.split("\t")
    taxids    = {
        list_line[0],#.split(".")[0],
        list_line[1]#.split(".")[0]
    }
    distance  = float(list_line[2])
    # print(taxids)
    
    if len(taxids.intersection(dico_annotation)) == 2 and distance < 0.5:
        # print(taxids)
        filtered_distance_matrix.write(l)
        

filtered_distance_matrix.close()
