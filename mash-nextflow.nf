#!/usr/bin/env nextflow



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
  echo true
  
  input:
  file genomesChunk

  output:
  file "${genomesChunk}.msh" into reference

  script:
  "mash sketch -i ${genomesChunk}"
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

  input:
  file genomeSketches

  output:
  file 'distance.tab' into distance

  """
  mash dist -t ${genomeSketches} ${genomeSketches} > distance.tab
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


