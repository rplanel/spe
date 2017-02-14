#!/bin/bash

out="/env/cns/home/rplanel/my_proj/test/mash/data/rand-index/progenome/rand-indexes-no-singleton.csv"

echo -e "distance Rand HA MA FM Jaccard" > $out

find /env/cns/home/rplanel/my_proj/test/mash/data/runs/progenome/na/one-nextflow/ -name work -prune -o -name distance-matrices -prune -o -name graph -prune -o -name trees -prune -o -name rand-index-no-singleton.csv -print | xargs cat >> $out
