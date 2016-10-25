#!/bin/bash


dir="./out"
mkdir -p $dir


# kmer=21
# sketchSize=1000

# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir


# ## 0.01
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.01 > $outDir/1-0.01.out
# sleep 5

# ## 0.02
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.02 > $outDir/1-0.02.out
# sleep 5


# ## 0.03

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.03 > $outDir/1-0.03.out
# sleep 5

# ## 0.05
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.05 > $outDir/1-0.05.out
# sleep 5

# #0.07
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.07 > $outDir/1-0.07.out
# sleep 5



# ## 0.1
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.1 > $outDir/1-0.1.out
# sleep 5


# ## 0.15
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.15 > $outDir/1-0.15.out
# sleep 5

# ## 0.2
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.2 > $outDir/1-0.2.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-15 --distance 0.2 > $outDir/1e-15-0.2.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-30 --distance 0.2 > $outDir/1e-30-0.2.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-50 --distance 0.2 > $outDir/1e-50-0.2.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-80 --distance 0.2 > $outDir/1e-80-0.2.out
# sleep 5

# ## 0.23
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.23 > $outDir/1-0.23.out
# sleep 5


# ## 0.25
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.25 > $outDir/1-0.25.out
# sleep 5


# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.26 > $outDir/1-0.26.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.27 > $outDir/1-0.27.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.28 > $outDir/1-0.28.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.29 > $outDir/1-0.29.out
# sleep 5


# ## 0.3
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.3 > $outDir/1-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-15 --distance 0.3 > $outDir/1e-15-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-30 --distance 0.3 > $outDir/1e-30-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-50 --distance 0.3 > $outDir/1e-50-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-80 --distance 0.3 > $outDir/1e-80-0.3.out
# sleep 5

# ## 0.5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.5 > $outDir/1-0.5.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-15 --distance 0.5 > $outDir/1e-15-0.5.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1E-30 --distance 0.5 > $outDir/1e-30-0.5.out
# sleep 5

# ## 1
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 1 > $outDir/1-1.out
# sleep 5



########################################################
## s=400 k=16


kmer=16
sketchSize=400
outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir



nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.03 > $outDir/1-0.03.out
sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.07 > $outDir/1-0.07.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.1 > $outDir/1-0.1.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.3 > $outDir/1-0.3.out
# sleep 5


#####################################################
# kmer=16
# sketchSize=5000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir



# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.03 > $outDir/1-0.03.out
# sleep 5


#############################################################
# ## s=5000 k=21
# kmer=21
# sketchSize=5000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir



# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.3 > $outDir/1-0.3.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1e-50 --distance 0.3 > $outDir/1e-50-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.2 > $outDir/1-0.2.out
# sleep 5


##################################################################
# ## s=5000 k=27
# kmer=27
# sketchSize=5000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.2 > $outDir/1-0.2.out
# sleep 5


# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.3 > $outDir/1-0.3.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1e-50 --distance 0.3 > $outDir/1e-50-0.3.out
# sleep 5


#####################################################################
# kmer=21
# sketchSize=10000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.2 > $outDir/1-0.2.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.3 > $outDir/1-0.3.out
# sleep 5
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1     --distance 0.4 > $outDir/1-0.4.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1e-50 --distance 0.3 > $outDir/1e-50-0.3.out
# sleep 5
