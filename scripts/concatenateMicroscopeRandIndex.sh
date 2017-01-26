#!/bin/bash

out="/env/cns/home/rplanel/my_proj/test/mash/data/rand-index/microscope"

module load r/3.3.1


for taxa in "species" "genus" "family" "order" "class" "phylum"
do
    echo $taxa_out
    taxa_out="$out/${taxa}-rand-indexes.csv"
    echo -e "distance Rand HA MA FM Jaccard" > $taxa_out 
    find /env/cns/home/rplanel/my_proj/test/mash/data/runs/microscope/na/21-1000/ -name work -prune -o -name distance-matrices -prune -o -name graph -prune -o -name trees -prune -o -name "rand-index-${taxa}.csv" -print | xargs cat >> $taxa_out
    Rscript /env/cns/home/rplanel/my_proj/test/mash/scripts/rand-index-plot.R $taxa_out "${taxa}-rand-index-plot.pdf"
done




