#!/bin/bash

out="/env/cns/home/rplanel/my_proj/test/mash/data/rand-index/progenome/rand-indexes.csv"

echo -e "distance Rand HA MA FM Jaccard" > $out

find /env/cns/home/rplanel/my_proj/test/mash/data/runs/progenome/na/21-1000/ -name work -prune -o -name distance-matrices -prune -o -name graph -prune -o -name trees -prune -o -name rand-index.csv -print | xargs cat >> $out
