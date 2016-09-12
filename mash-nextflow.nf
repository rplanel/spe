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



/*
 * Given a genome, create a channel emitting the fasta file.
 * The file file is split in chunks containing as many sequences as defined by the parameter 'chunkSize'
 * Finally, assign the result channel to the variable genomesChunk.
 */
mergedGenomes
.splitFasta(by: params.chunkSize)
.set { genomesChunk }

// Calculate the sketches 
process sketch {
  
  maxForks 1
  
  input:
  file genomesChunk

  output:
  file "${genomesChunk}.msh" into reference

  script:
  "mash sketch -s 400 -k 16 -i ${genomesChunk}"
}


reference
.collectFile() {file ->
  [ 'sketches-filenames.txt', file.toString() + '\n' ]
 }
.set { sketchesFilename }


process pasteSketches {

  input:
  file sketchesFilename


  output:
    file 'genome-sketches.msh' into genomeSketches

  script:
  "mash paste genome-sketches -l ${sketchesFilename} "

}



// Calculate the distances
process distance {
  publishDir 'result'
  
  input:
  file genomeSketches

  output:
  file 'distance.tab' into distance

  """
  mash dist -v 1e-10 -d 0.05 -t ${genomeSketches} ${genomeSketches} > distance.tab
  """
}




// Process that sort the distance output
// process sort {

//   input:
//   file distance

//   output:
//   file 'distance-sort.tab'

//   """
//   sort -gk3 ${distance} > distance-sort.tab
//   """
// }


