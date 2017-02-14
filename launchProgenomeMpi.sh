#!/bin/bash
#SBATCH -p normal
#SBATCH --mem 40960
#SBATCH -n 48
#SBATCH -N 2
#SBATCH --ntasks-per-node=24
##       //  #SBATCH --exclusive
##       //  #SBATCH --threads-per-core=1

#export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)
# -with-dag workflow.pdf
rootDir="/env/cns/home/rplanel/my_proj/test/mash"
kmer=21
sketchSize=5000
p=1E-10
seqType="na"
seqSrc="progenome"

#--distance $d \
#for d in 0.01 0.02 0.025 0.03 0.035 0.04 0.045 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14
# for d in 0.01
# do



workDir="${rootDir}/data/runs"
echo $workDir
mkdir -p $workDir
mkdir -p "${workDir}/${seqSrc}/${seqType}/${kmer}-${sketchSize}"
cd  $workDir

#     -pool-size 1 \
#       -profile cluster \

mpirun --pernode \
       mash-nextflow.nf \
       -with-mpi \
       -resume \
       -c "${rootDir}/scripts/nextflow/nextflow.config" \
       -w work -with-timeline -with-trace \
       --progenome "$rootDir/data/progenome/all-contigs-progenomes.fna.gz" \
       --progenomeClusters "$rootDir/data/progenome/specIv2.clustering.map.txt" \
       --seqType $seqType \
       --seqSrc $seqSrc \
       --sketchSize $sketchSize \
       --kmerSize $kmer \
       --pvalue $p \
       --scripts "$rootDir/scripts" \
       --dataDir "$rootDir/data" > "${workDir}/${seqSrc}/${seqType}/${kmer}-${sketchSize}/nextflow.out"
