#!/bin/bash

# -with-dag workflow.pdf

dir="./out"
mkdir -p $dir


kmer=21
sketchSize=1000

outDir="$dir/aa/${kmer}-${sketchSize}"
mkdir -p $outDir

p=1E-10

#for d in 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1
#for d in 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14
for d in 0.03
do
    workDir="data/runs/na/${kmer}-${sketchSize}/${p}-${d}"
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



#nextflow run mash-nextflow.nf -resume -w /env/cns/home/rplanel/my_proj/test/mash/data/runs/aa/9-1000/1.0E-10-0.03/work --sketchSize 1000 --kmerSize 9 --pvalue 1.0E-10 --distance 0.03 --seqType aa --scripts scripts --dataDir /env/cns/home/rplanel/my_proj/test/mash/data -with-timeline -with-trace -c nextflow-aa-na.config --cpus 1 --seqDir /env/cns/home/rplanel/my_proj/test/mash/data/proteome
