#!/bin/bash



nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1 --distance 0.03 > 1-0.03.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1 --distance 0.05 > 1-0.05.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1 --distance 0.07 > 1-0.07.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-30 --distance 0.03 > 1e-30-0.03.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-30 --distance 0.05 > 1e-30-0.05.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-30 --distance 0.07 > 1e-30-0.07.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-15 --distance 0.03 > 1e-15-0.03.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-15 --distance 0.05 > 1e-15-0.05.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-15 --distance 0.07 > 1e-15-0.07.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1 --distance 0.2 > 1-0.2.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-15 --distance 0.2 > 1e-15-0.2.out
nohup nextflow run mash-nextflow.nf -bg -profile cluster -w data/work -with-timeline -with-trace -with-dag workflow.pdf --sketchSize 1000 --kmerSize=21 --cpus 1 --pvalue 1E-30 --distance 0.2 > 1e-30-0.2.out
