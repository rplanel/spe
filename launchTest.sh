#!/bin/bash

# -with-dag workflow.pdf

dir="./out"
mkdir -p $dir


kmer=21
sketchSize=1000

outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir



# d=0.03
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.037
# p=1e-10
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# jobify -c 1 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.038
# p=1e-10
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# jobify -c 1 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.039
# p=1e-10
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# jobify -c 1 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



# d=0.04
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



# d=0.05
# p=1e-10
# jobify -c 8 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.06
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.065
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.07
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

d=0.075
p=1e-10
#nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
jobify -c 8 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 8 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
echo "$sketchSize - $kmer - $d - $p"
sleep 5


# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.09
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.1
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.11
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



# d=0.12
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.125
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



# d=0.13
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.14
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.15
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.16
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.17
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5




#######################################################################
kmer=21
sketchSize=5000
outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir


# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.10
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



########################################################
## s=400 k=16


kmer=16
sketchSize=400
outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir

# d=0.03
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.035
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.037
# p=1e-10
# jobify -c 8 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.04
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.05
# p=1e-10
# # nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# jobify -c 8 nextflow run mash-nextflow.nf -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.06
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.07
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.09
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.1
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.11
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.12
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.13
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.14
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.15
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.1
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.15
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5




# d=0.2
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.03 > $outDir/1-0.03.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.07 > $outDir/1-0.07.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.1 > $outDir/1-0.1.out
# sleep 5

# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue 1 --distance 0.3 > $outDir/1-0.3.out
# sleep 5

#######################################################################
# kmer=16
# sketchSize=1000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir


# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5




#######################################################################
kmer=16
sketchSize=5000
outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir


# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.10
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.12
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5




#############################################################
## s=5000 k=21
kmer=21
sketchSize=5000
outDir="$dir/${kmer}-${sketchSize}"
mkdir -p $outDir

# d=0.08
# p=1e-10
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5



# d=0.2
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# ##################################################################
# ## s=5000 k=27
# kmer=27
# sketchSize=5000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir


# d=0.3
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.2
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# #####################################################################
# kmer=21
# sketchSize=10000
# outDir="$dir/${kmer}-${sketchSize}"
# mkdir -p $outDir


# d=0.1
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5


# d=0.2
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

# d=0.3
# p=1e-100
# nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace --sketchSize $sketchSize --kmerSize=$kmer --cpus 1 --pvalue $p --distance $d > "$outDir/${p}-${d}.out"
# echo "$sketchSize - $kmer - $d - $p"
# sleep 5

