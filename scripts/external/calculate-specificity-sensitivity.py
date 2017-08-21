#!/usr/bin/env python

import argparse
import sys
import os.path

parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--clustering",
    nargs='?',
    type = argparse.FileType('r'),
    default=sys.stdin,
    help = "File that contains the clustering to compare"
)

parser.add_argument(
    "-o", "--output",
    nargs='?',
    type = argparse.FileType('w'),
    help = "File that contains the distances between each genomes (on distance per-line)"
)


def clustering_to_link(clustering) :
    truth_list = list()
    for i, item in enumerate(clustering, start=0):
        j = i + 1
        while j < len(clustering):
            if item == clustering[j]:
                truth_list.append(True)
            else:
                truth_list.append(False)
            j = j+1
    return truth_list

def table_truth(to_test, ref):
    
    table_truth_dic = {
        'TP': 0.,
        'FP': 0.,
        'FN': 0.,
        'TN': 0.,
    }
    zipped = zip(to_test, ref)
    # print(zipped)
    for it in zipped:
        if it[0] == it[1]:
            if it[1] == True: ## TP
                table_truth_dic['TP'] = table_truth_dic['TP'] + 1
            else:
                table_truth_dic['TN'] = table_truth_dic['TN'] + 1
        else:
            if it[1] == True: ## FN
                table_truth_dic['FN'] = table_truth_dic['FN'] + 1
            else:
                table_truth_dic['FP'] = table_truth_dic['FP'] + 1
                
    return table_truth_dic
        
args = parser.parse_args()

clustering_to_estimate = []
ref_clustering = []

for line in args.clustering:
    line_tr   = line.strip()
    columns   = line_tr.split("\t")
    clustering_to_estimate.append(int(columns[0]))
    ref_clustering.append(int(columns[1]))




to_test_link = clustering_to_link(clustering_to_estimate)
# print(to_test_link)
ref_link = clustering_to_link(ref_clustering)
# print(ref_link)
table_truth = table_truth(to_test_link, ref_link)
# print(table_truth)




sensitivity = table_truth['TP'] / (table_truth['TP'] + table_truth['FN'])

specificity = 1
if (table_truth['TN'] + table_truth['FP']) != 0:
    specificity = table_truth['TN'] / (table_truth['TN'] + table_truth['FP'])


# print("sensitivity\tspecificity")
print(str(sensitivity) + '\t' + str(specificity))
