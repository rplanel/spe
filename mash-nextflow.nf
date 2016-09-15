#!/usr/bin/env nextflow



println "Project : $workflow.projectDir"
println "Cmd line : $workflow.commandLine"
println "Work dir : $workflow.workDir"

/*
* These default parameters will be overwrite by user input:
* nextflow run mash-nextflow.nf --query /path/to/file --chunksize 10
*/
params.query
params.chunkSize = 1
params.sketch


sketchesOutName = "sketches-db"

mergeFastaScript = Channel.fromPath('scripts/mergeGenomes.pl')
query            = Channel.fromPath(params.query)





process merge_same_organism {
  tag { query }
  input:
  file query
  file mergeFastaScript

  output:
  file out into mergedGenomes

  script:
  baseName = query.getBaseName()
  out      = "${baseName}.merged.fasta"
  "perl ${mergeFastaScript} ${query} ${out}"
}



// Calculate the sketches 
process sketch {
  tag { mergedGenomes }
  maxForks 1
  
  input:
  file mergedGenomes

  output:
  file "${baseName}.msh" into querySketch

  script:
  baseName = mergedGenomes.getBaseName()
  
  "mash sketch -s 400 -k 16 -i ${mergedGenomes} -o $baseName"
}




allVsAllQuery    = Channel.create()
incrementalQuery = Channel.create()
querySketch.choice( allVsAllQuery, incrementalQuery ) { (params.sketch == null ) ? 0 : 1 }


sketchesDB = Channel.create()
if (params.sketch != null) {
  println 'Skectch'
  sketchesDB    = Channel.fromPath(params.sketch)
}


/*
 * Duplicate incrementalQuery channel : - One to pasteSketch process
 *                                      - The other to calculate dist
 */
incrementalQuery.into {queryToSketch; queryToDist}



// Calculate the distances
process all_vs_all_distance {
  publishDir 'result'

  input:
  file querySketch from allVsAllQuery
  
  output:
  file out into allVsAllDistances
  file "${sketchesOutName}.msh" into allSketchesDB

  script:
  baseName = querySketch.getBaseName()
  out = "${baseName}.distance.tab"
  """
  mash dist -v 1e-10 -d 0.05 -t ${querySketch} ${querySketch} > $out
  mv $querySketch ${sketchesOutName}.msh
  """

}


process paste_sketch_to_db {
  publishDir 'result'
  
  input:
  file querySketch from queryToSketch
  file sketchesDB

  output:
  file  "${sketchesOutName}.msh" into updatedSketchesDB

  script:
  bak = sketchesDB.getBaseName() + ".bak.msh"
  filename = sketchesDB.getName()
  
  """
  mv $filename $bak
  mash paste ${sketchesOutName} $bak $querySketch
   
  """
  
}





process incremental_distance {
  publishDir 'result'
  
  input:
  file querySketch from queryToDist
  file sketches from updatedSketchesDB
  
  output:
  file out into queryDistanceResult
  
  script:
  baseName = querySketch.getBaseName()
  out      = "${baseName}.distance.tab"
  """
  mash dist -v 1e-10 -d 0.05 -t ${sketches} ${querySketch} > $out
  """
  
}

