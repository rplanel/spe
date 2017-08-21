#!/usr/bin/env python

import os
import argparse
import sys

parser = argparse.ArgumentParser()
# parser.add_argument(
#     "-e", "--edges",
#     nargs='?',
#     type = argparse.FileType('r'),
#     default=sys.stdin,
#     help = "File that contains the distances between each genomes (on distance per-line)"
# )

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

# args = parser.parse_args()


out_dir = './metric-results'
out_basename = out_dir + '/clustering-similarity-result'
#sketch_sizes = ['21-1000', '21-50000', '16-50000', '19-50000', '25-50000']
sketch_sizes = [
    # '7-5000',
    # '6-5000',
    # '8-5000', 
    # '16-1000',
    # '16-50000',
    # '17-50000',
    '18-1000',
    '18-10000',
    '18-5000',
    '18-50000',
    # '19-1000',
    # '19-50000',
    '21-1000',
    '21-50000',
    '21-5000',
    '21-10000',
    # '25-1000',
    # '25-50000',
]


if not os.path.exists(out_dir):
    os.makedirs(out_dir)


#cluster_methods = ['silix', 'louvain', 'weighted_louvain','infomap']
cluster_methods = [
    'louvain',
    # 'weighted_louvain',
    'silix',
    # 'infomap'
]

versus = [
    {'vs' : 'rank'     ,'rank': 'species' },
    {'vs' : 'rank'     ,'rank': 'genus'   },
    {'vs' : 'rank'     ,'rank': 'family'  },
    {'vs' : 'rank'     ,'rank': 'order'  },
    {'vs' : 'progenome','rank': 'cluster'}
]


for metric in ["variation-of-information"]:
    for vs in versus:
        results   = dict()
        distances = []
        header    = ['distance', 'metric', 'clustering-method', 'sketch-size']

        fh_o = open(out_basename + '-'+ metric + '-' + vs['rank']+'.tsv', 'w')
        fh_o.write('\t'.join(header) + "\n")

        for size in sketch_sizes:
            for method in cluster_methods:
                fh = open(size + '/'+ metric+ '/' + method + '-vs-' + vs['vs'] + '-'+ metric +'-' + vs['rank'] + '-0.tsv', 'r')
                fh.readline()
                dico = dict()

                for line in fh:
                    line_tr = line.strip()
                    columns = line_tr.split(' ')
                    columns.append(method)
                    columns.append(size)
                    fh_o.write('\t'.join(columns) + "\n")
                


for metric in []: #["split-join"]:
    for vs in versus:
        results   = dict()
        distances = []
        header    = ['distance', 'metric', 'clustering-method', 'sketch-size']

        fh_o = open(out_basename + '-'+ metric + '-' + vs['rank']+'.tsv', 'w')
        fh_o.write('\t'.join(header) + "\n")

        for size in sketch_sizes:
            for method in cluster_methods:
                fh = open(size + '/'+ metric+ '/' + method + '-vs-' + vs['vs'] + '-'+ metric +'-' + vs['rank'] + '.csv', 'r')
                fh.readline()
                dico = dict()

                for line in fh:
                    line_tr = line.strip()
                    columns = line_tr.split(' ')
                    if len(columns) == 4:
                        columns.pop(1)
                        columns.pop(1)
                        columns.append(method)
                        columns.append(size)
                        fh_o.write('\t'.join(columns) + "\n")
                



                
metric='rand-index'
for vs in versus:
    results   = dict()
    distances = []
    header    = ['distance', 'metric', 'clustering-method', 'sketch-size']

    fh_o = open(out_basename+ '-' + metric + '-' + vs['rank']+'.tsv', 'w')
    fh_o.write('\t'.join(header) + "\n")
    
    for size in sketch_sizes:
        for method in cluster_methods:
            if vs['rank'] == 'cluster':
                fh = open(size + '/'+ metric+ '/vs-' + vs['vs'] + '/vs-' +  vs['vs'] + '-rand-indexes-' + method + '-0.tsv', 'r')
            else:
                fh = open(size + '/'+ metric+ '/vs-' + vs['vs'] + '/csv/' + method + '-vs-' +  vs['vs'] + '-rand-indexes-' + vs['rank'] + '.csv', 'r')
            
            fh.readline()
            dico = dict()

            for line in fh:
                line_tr = line.strip()
                columns = line_tr.split(' ')
                line_res = [columns[0], columns[3]]
                line_res.append(method)
                line_res.append(size)
                fh_o.write('\t'.join(line_res) + "\n")


