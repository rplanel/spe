#!/bin/bash

# -with-dag workflow.pdf
rootDir="/home/rplanel/test/mash/mash-test"
kmer=21
sketchSize=1000
p=1E-10
seqType="na"
seqSrc="progenome"

# for d in 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14
for d in 0.03
do
    workDir="data/runs/${seqSrc}/${seqType}/${kmer}-${sketchSize}/${p}-${d}"
    echo $workDir
    mkdir -p $workDir
    cd  $workDir
    mash-nextflow.nf \
	-resume \
	-c "${rootDir}/scripts/nextflow/nextflow.config" \
	-w work -with-timeline -with-trace \
	-qs 10 \
	--progenome "$rootDir/data/progenome/all-contigs-progenomes.fna.gz" \
	--progenomeClusters "$rootDir/data/progenome/specIv2.clustering.map.txt" \
	--seqType $seqType \
	--seqSrc $seqSrc \
	--sketchSize $sketchSize \
	--kmerSize $kmer \
	--pvalue $p \
	--distance $d \
	--scripts "$rootDir/scripts" \
	--dataDir "$rootDir/data" > nextflow.out
    cd ../../../../../../
    sleep 5
    
done




