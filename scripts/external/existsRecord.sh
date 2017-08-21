#!/bin/bash


distance=$1
pvalue=$2
kmerSize=$3
sketchSize=$4
seqType=$5

hasParams=`mysql GO_SPE -ABNre "SELECT EXISTS(SELECT MASH_param_id FROM MASH_param WHERE distance = $distance AND pvalue = $pvalue AND kmer_size = $kmerSize AND sketch_size = $sketchSize);"`



if [ $hasParams -ne 0 ]
then
    res=`mysql GO_SPE -ABNre "SELECT MASH_param_id FROM MASH_param WHERE distance = $distance AND pvalue = $pvalue AND kmer_size = $kmerSize AND sketch_size = $sketchSize;"`
    echo $res
    exit 0
else
    mysql GO_SPE -ABNre "INSERT INTO MASH_param (distance, pvalue, kmer_size, sketch_size) VALUES ($distance, $pvalue, $kmerSize, $sketchSize);"
    
    if [ $? -eq 0 ]
    then
	res=`mysql GO_SPE -ABNre "
             SELECT MASH_param_id 
             FROM MASH_param 
             WHERE distance = $distance 
               AND pvalue = $pvalue 
               AND kmer_size = $kmerSize 
               AND sketch_size = $sketchSize;"`
	
	echo $res
	exit 0
    else
	exit 1
    fi
fi

exit 0
