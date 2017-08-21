#!/usr/bin/env python3

import sys
import re
# from functools import reduce

cluster_file  = open(sys.argv[1], 'r')
mash_param_id = sys.argv[2]


for line in cluster_file:
    stripped_line = line.strip()
    if stripped_line != '':
        list_column = stripped_line.split("\t")
        ## clean cluster id
        cluster_id = list_column[0].replace("CL","")
        print(mash_param_id + "\t" + cluster_id + "\t" + list_column[1])
