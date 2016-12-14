#!/usr/bin/env nextflow


println "Project  : $workflow.projectDir"
println "Cmd line : $workflow.commandLine"
println "Work dir : $workflow.workDir"
println "Profile  : $workflow.profile"
println "scripts  : $params.scripts"


/*
* WORKFLOW PARAMETERS
* These default parameters will be overwrite by user input:
* nextflow run mash-nextflow.nf --query /path/to/file --chunksize 10
*/
//params.query
params.sketches
//params.genomes
params.oid
params.cpus
params.pvalue
params.distance
params.sketchSize
params.kmerSize
// params.scripts
params.dataDir


sketchesOutName = "sketches-db"

/****
 * SCRIPTS
 ****/
extractOrgSeq        = Channel.value(file("${params.scripts}/extractOrgSeq.sh"))
mergeFastaScript     = Channel.value(file("${params.scripts}/mergeGenomes.pl"))
splitFastaScript     = Channel.value(file("${params.scripts}/splitFasta.pl"))
clusterGenomes       = Channel.value(file("${params.scripts}/nextflow/mash-nextflow.nf"))
scripts              = Channel.value(file(params.scripts))
dataDir              = Channel.value(file(parmas.dataDir))
nextflowConfig       = Channel.value(file("${params.scripts}/nextflow/nextflow-aa-na.config"))
/*********************
 * Values parameters *
 *********************/
pvalueThreshold   = Channel.value(params.pvalue)
distanceThreshold = Channel.value(params.distance)
sketchSize        = Channel.value(params.sketchSize)
kmerSize          = Channel.value(params.kmerSize)



oid = Channel.empty()
//query = Channel.empty()

if (params.oid != null) {
  oid = Channel.value(params.oid)
}



process getGenome {
  tag { oid }
  storeDir { storeDir }
  
  input:
  val oid
  val dataDir

  output:
  file "${filenameOut}" into genome
  
  script:
  filenameOut = "${oid}.fasta"
  storeDir = "${dataDir}/genomes"
  """
  mysql --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
    \"SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string) \
    FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) \
    INNER JOIN Sequence_String USING(S_id) \
    WHERE rank = 'order' AND S_status = 'inProduction' AND O_id=${oid}\" >  ${filenameOut}
  """
}



process getGenomes {
  storeDir { storeDir }

  input:
  file script from extractOrgSeq
  val dataDir
  
  output:
  file "*.fna" into genomes
  
  script:
  storeDir = "${dataDir}/genome"
  """
  bash ${script}
  """
}



genomesInputs = Channel.empty()
genomesInputs.mix(genome,genomes)
.flatten()
.tap { countFasta }
.set { genomesInput}


/*
* Get the num of fasta
*/
numOfFasta = countFasta.count()


process sketch {
  
  tag { genomes }
  storeDir { storeDir }
  errorStrategy 'retry'
  queue 'normal'
  //maxRetries 5
  // cpus params.cpus
  // maxForks params.cpus
  
  input:
  file genomes from genomesInput
  val sketchSize
  val kmerSize  
  val dataDir
  
  output:
  file "${out}.msh" into querySketch

  script:
  storeDir = "${dataDir}/sketch/na/${kmerSize}/${sketchSize}"
  baseName = genomes.getBaseName()
  out = "${baseName}"
  """
  mash sketch -s ${sketchSize} -k ${kmerSize} ${genomes} -o $out
  """
  
}


querySketch
.collectFile() {file ->
  [ 'sketches-filenames.txt', file.toString() + '\n' ]
 }
.into { sketchesFilenameToPaste;  sketchesFilenameToDist; sketchesFilenameToDistUpdate }


process paste_query_sketches_together {
  tag { filesList }
  // Do not store dir because will not redo this file if use a subset.
  storeDir { storeDir }

  queue 'normal'
  
  input:
  file filesList from sketchesFilenameToPaste
  val sketchSize
  val kmerSize
  val dataDir
  
  output:
  file "${out}.msh" into genomeSketches
  
  script:
  storeDir = "${dataDir}/sketch/na/paste"
  out = "genome-sketches-${kmerSize}-${sketchSize}"
  "mash paste ${out} -l ${filesList}"

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
  tag { "${query} distance=${sketchSize} pvalue=${kmerSize} $sketchesDb" } 
  
  //scratch true
  storeDir { storeDir }
  
  input:
  file sketchesDb from allVsAllQuery
  file query from sketchesFilenameToDist
  val sketchSize
  val kmerSize  
  val dataDir
  
  output:
  file out into allVsAllDistances

  script:
  storeDir= "${dataDir}/distance/na"
  baseName = sketchesDb.getBaseName()
  out = "${baseName}-distance.tab"

  // mash dist -v $pvalueThreshold -d $distanceThreshold ${sketchesDb} -l ${query} > $out
  """
  mash dist ${sketchesDb} -l ${query} | perl -pe 's/\\.fna//g' > $out
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
  publishDir { resultDir }
  
  input:
  file querySketch from sketchesFilenameToDistUpdate
  file sketches from updatedSketchesDB
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  
  
  
  output:
  file out into queryDistanceResult
  
  script:
  resultDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  baseName = querySketch.getBaseName()
  out      = "${baseName}-${distanceThreshold}-${pvalueThreshold}-distance.tab"
  """
  mash dist -v $pvalueThreshold -d $distanceThreshold ${sketches} -l ${querySketch} > $out
  """
  
}




process clusterGenomes {

  input:
  file script from clusterGenomes
  file distance from allVsAllDistances
  file scripts
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize
  val numOfFasta
  val dataDir

  script:
  runDir = "${dataDir}/runs/na/${kmerSize}-${sketchSize}/${pvalueThreshold}-${distanceThreshold}"
  """
  nextflow run ${script} -resume -w ${runDir}/work k --sketchSize $sketchSize --kmerSize $kmerSize --pvalue $pvalueThreshold --distance $distanceThreshold --distanceMatrix $distance --seqType na --qs ${params.cpus} --scripts ${scripts} --countSeq ${numOfFasta} --dataDir ${dataDir}
  """
  
}
