#!/bin/bash

# -with-dag workflow.pdf

kmer=21
sketchSize=1000
p=1E-10


for d in 0.7
do
    workDir="data/runs/progenome/${kmer}-${sketchSize}/${p}-${d}"
    echo $workDir
    mkdir -p $workDir
    cd  $workDir
    nohup mash-aa-distance.nf \
	  -resume \
	  -c /env/cns/home/rplanel/my_proj/test/mash/scripts/nextflow/nextflow.config \
	  -bg -profile cluster \
	  -w work -with-timeline -with-trace \
	  -qs 10 \
	  --seqType na \
	  --seqSrc progenome \
	  --progenome /env/cns/home/rplanel/my_proj/test/mash/data/progenome/representatives.genes.fasta \
	  --sketchSize $sketchSize \
	  --kmerSize $kmer \
	  --cpus 2 \
	  --pvalue $p \
	  --distance $d \
	  --scripts /env/cns/home/rplanel/my_proj/test/mash/scripts \
	  --dataDir /env/cns/home/rplanel/my_proj/test/mash/data > nextflow.out
    cd ../../../../../
    sleep 5
    
done
