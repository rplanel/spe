#!/bin/bash


for f in `find ./data/runs/  -maxdepth 5 -name work -prune -o -name "*edges-annotated.silix" -print`
do
    ./scripts/extractClusters4RandIndex.pl $f
done
