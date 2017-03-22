#!/bin/bash


rootDir="/env/cns/home/rplanel/my_proj/test/mash"
kmer=21
sketchSize=1000
p=1E-10
seqType="na"
seqSrc="progenome-test"


workDir="${rootDir}/data/runs"
echo $workDir
mkdir -p $workDir
mkdir -p "${workDir}/${seqSrc}/${seqType}/${kmer}-${sketchSize}"
cd  $workDir

#     -pool-size 1 \

mash-nextflow.nf \
    -resume \
    -profile cluster \
    -c "${rootDir}/scripts/nextflow/nextflow.config" \
    -w work -with-timeline -with-trace -with-dag "workflow-${seqSrc}.pdf" \
    --progenome "$rootDir/data/progenome/test-species-clusters.fna.gz" \
    --progenomeClusters "$rootDir/data/progenome/specIv2.clustering.map.txt" \
    --seqType $seqType \
    --seqSrc $seqSrc \
    --sketchSize $sketchSize \
    --kmerSize $kmer \
    --pvalue $p \
    --bsTree 250 \
    --bsExtractDstanceMatrix 250 \
    --scripts "$rootDir/scripts" \
    --dataDir "$rootDir/data" > "${workDir}/${seqSrc}/${seqType}/${kmer}-${sketchSize}/nextflow.out"




