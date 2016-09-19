#!/usr/bin/env nextflow



println "Project  : $workflow.projectDir"
println "Cmd line : $workflow.commandLine"
println "Work dir : $workflow.workDir"
println "Profile  : $workflow.profile"
/*
* WORKFLOW PARAMETERS
* These default parameters will be overwrite by user input:
* nextflow run mash-nextflow.nf --query /path/to/file --chunksize 10
*/
//params.query
params.sketches
params.genomes
params.numOfGenomes
params.oid
params.cpus






sketchesOutName = "sketches-db"

mergeFastaScript = Channel.value(file('scripts/mergeGenomes.pl'))
splitFastaScript = Channel.value(file('scripts/splitFasta.pl'))


//genomes = Channel.fromPath(params.genomes+'/*.fasta')

/*
if (params.oid != null && params.numOfGenomes != null) {
  error "ERROR parameters\nThe --oid and --numOfGenomes are incompatible."
  
}
*/

numOfGenomes = Channel.empty()
oid = Channel.empty()
//query = Channel.empty()

if (params.oid != null) {
  oid = Channel.value(params.oid)
}


if (params.numOfGenomes != null) {
  numOfGenomes = Channel.value(params.numOfGenomes)
}
else if (params.oid == null) {
  numOfGenomes = Channel.value('all')
}
else {
numOfGenomes = Channel.empty()
}


// if (params.query != null) {
//   query = Channel.fromPath(params.query)
// }

process getGenome {
  tag { oid }
  storeDir 'data/genomes'
  
  input:
  val oid

  output:
  file "${filenameOut}" into genome
  
  script:
  filenameOut = "${oid}.fasta"
  """
  mysql --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
    \"SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string) \
    FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) \
    INNER JOIN Sequence_String USING(S_id) \
    WHERE rank = 'order' AND S_status = 'inProduction' AND O_id=${oid}\" >  ${filenameOut}
  """
}

process getGenomes {
  tag { numOfGenomes }
  storeDir 'data/genomes'

  input:
  val numOfGenomes

  output:
  file "$filenameOut" into genomes
  
  script:
  filenameOut = "mic_${numOfGenomes}.fasta"

  if (numOfGenomes == 'all')
    """
    mysql --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
    \"SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string) \
    FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) \
    INNER JOIN Sequence_String USING(S_id) \
    WHERE rank = 'order' AND S_status = 'inProduction'\" >  ${filenameOut}
    """
  else
    """
    mysql --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
    \"SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string) \
    FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) \
    INNER JOIN Sequence_String USING(S_id) \
    WHERE rank = 'order' AND S_status = 'inProduction' LIMIT ${numOfGenomes} \" >  ${filenameOut}
    """
}






genomesInputs = Channel.empty()
//genomesInput = Channel.create()
genomesInputs.mix(genome,genomes)
.toList()
.set { genomesInput}



process merge_same_organism {
  tag { g }
  
  input:
  each g from genomesInput 
  file mergeFastaScript

  output:
  file out into mergedGenomes

  script:
  baseName = g.getBaseName()
  out      = "${baseName}.merged.fasta"
  "perl ${mergeFastaScript} ${g} ${out}"
}




process splitFasta {
  tag { mergedGenomes }
  
  input:
  file mergedGenomes
  file script from splitFastaScript
  
  output:
  file "${outdir}/*.fasta" into fastaGenomes mode flatten

  script:
  outdir = "per_oid"
  f = file("$outdir")
  f.mkdir()
  """
  perl ${script} ${mergedGenomes} ${outdir}
  """
}




/*  Calculate the sketches */


process sketch {
  tag { genomes }
  storeDir 'data/sketches'
  afterScript 'date'
  maxRetries 5
  cpus params.cpus
  maxForks params.cpus
  
  input:
  file genomes from fastaGenomes

  output:
  file "${baseName}.msh" into querySketch

  script:
  baseName = genomes.getBaseName()
  "mash sketch -s 400 -k 16 -i ${genomes} -o $baseName"
  
}



querySketch
.collectFile() {file ->
  [ 'sketches-filenames.txt', file.toString() + '\n' ]
 }
.into { sketchesFilenameToPaste;  sketchesFilenameToDist; sketchesFilenameToDistUpdate }


process paste_query_sketches_together {
  
  input:
  file filesList from sketchesFilenameToPaste
  
  output:
  file 'genome-sketches.msh' into genomeSketches

  script:
  "mash paste genome-sketches -l ${filesList}"

}


allVsAllQuery    = Channel.create()
incrementalQuery = Channel.create()
genomeSketches.choice( allVsAllQuery, incrementalQuery ) { (params.sketches == null ) ? 0 : 1 }


sketchesDB = Channel.empty()
if (params.sketches != null) {
  Channel
  .fromPath(params.sketches+"/*.msh")
  .collectFile() {file ->
    [ 'sketches-filenames.txt', file.toString() + '\n' ]
  }
  .into { sketchesDB}
}


/*
 * Duplicate incrementalQuery channel : - One to pasteSketch process
 *                                      - The other to calculate dist
 */
incrementalQuery.into {queryToSketch; queryToDist}



// Calculate the distances
process all_vs_all_distance {
  tag { query }
  publishDir 'result', mode: 'copy', overwrite: true

  input:
  file sketchesDb from allVsAllQuery
  file query from sketchesFilenameToDist
  
  output:
  file out into allVsAllDistances

  script:
  baseName = sketchesDb.getBaseName()
  out = "${baseName}.distance.tab"
  """
  mash dist ${sketchesDb} -l ${query} > $out
  """

}


process paste_sketch_to_db {
  tag { sketchesList }
  input:
  file sketchesList from sketchesDB

  output:
  file  "${prefix}.msh" into updatedSketchesDB

  script:
  prefix = 'sketchesDB'
  
  """
  mash paste ${prefix} -l ${sketchesList}
  """
  
}





process incremental_distance {
  publishDir 'result'
  
  input:
  file querySketch from sketchesFilenameToDistUpdate
  file sketches from updatedSketchesDB
  
  output:
  file out into queryDistanceResult
  
  script:
  baseName = querySketch.getBaseName()
  out      = "${baseName}.distance.tab"
  """
  mash dist ${sketches} -l ${querySketch} > $out
  """
  
}


workflow.onComplete {
  println "Pipeline execution summary"
  println "---------------------------"
  println "Completed at: ${workflow.complete}"
  println "Duration    : ${workflow.duration}"
  println "Success     : ${workflow.success}"
  println "workDir     : ${workflow.workDir}"
  println "exit status : ${workflow.exitStatus}"
  println "Error report: ${workflow.errorReport ?: '-'}"
}
