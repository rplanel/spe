# coding: utf-8
 
#from data import *
MIN_SIZE = 1


def bronker_bosch1(clique, candidates, excluded, reporter, NEIGHBORS):
    '''Naive Bron-Kerbosch algorithm'''
    reporter.inc_count()
    if not candidates and not excluded:
        if len(clique) >= MIN_SIZE:
            reporter.record(clique)
        return
 
    for v in list(candidates):
        new_candidates = candidates.intersection(NEIGHBORS[v])
        new_excluded = excluded.intersection(NEIGHBORS[v])
        bronker_bosch1(clique + [v], new_candidates, new_excluded, reporter, NEIGHBORS)
        candidates.remove(v)
        excluded.add(v)
