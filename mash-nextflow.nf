#!/usr/bin/env nextflow



println "Project : $workflow.projectDir"
println "Cmd line : $workflow.commandLine"
println "Work dir : $workflow.workDir"

/*
* These default parameters will be overwrite by user input:
* nextflow run mash-nextflow.nf --genomes /path/to/file --chunksize 10
*/
params.genomes='data/genome/mic100.fasta'
params.chunkSize = 100
params.update

mergeFasta = Channel.fromPath('scripts/mergeGenomes.pl')
genomes    = Channel.fromPath(params.genomes)




process mergeSameOrganism {

  input:
  file genomes
  file mergeFasta

  output:
  file "${genomes}.merged" into mergedGenomes

  script:
  "perl ${mergeFasta} ${genomes} ${genomes}.merged"
}



// Calculate the sketches 
process sketch {
  
  maxForks 1
  
  input:
  file mergedGenomes

  output:
  file "${mergedGenomes}.msh" into reference

  script:
  "mash sketch -s 400 -k 16 -i ${mergedGenomes}"
}


// Calculate the distances
process distance {
  publishDir 'result'
  
  input:
  file reference

  output:
  file 'distance.tab' into distance

  """
  mash dist -v 1e-10 -d 0.05 -t ${reference} ${reference} > distance.tab
  """
}



