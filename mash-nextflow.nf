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
//params.genomes
params.numOfGenomes
params.oid
params.cpus
params.pvalue
params.distance
params.sketchSize
params.kmerSize




sketchesOutName = "sketches-db"


/*
 * SCRIPTS
 */
mergeFastaScript     = Channel.value(file('scripts/mergeGenomes.pl'))
splitFastaScript     = Channel.value(file('scripts/splitFasta.pl'))
filterGraphScript    = Channel.value(file('scripts/filterGraph.pl'))
addAnnotationScript  = Channel.value(file('scripts/addAnnotation.pl'))
extractClusterScript = Channel.value(file('scripts/extractCluster.pl'))
calculateClusterIntraStatScript = Channel.value(file('scripts/calculateClusterIntraStat.pl'))

indexHtml = Channel.value(file('scripts/index.html'))
indexJs   = Channel.value(file('scripts/index.js'))
piechart  = Channel.value(file('scripts/piechart.js'))


/*
 * Values parameters
 */
pvalueThreshold   = Channel.value(params.pvalue)
distanceThreshold = Channel.value(params.distance)
sketchSize        = Channel.value(params.sketchSize)
kmerSize          = Channel.value(params.kmerSize)


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
  storeDir 'data/genomes'
  

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
  file "${outdir}/*.fasta" into countFasta, fastaGenomes mode flatten
  
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
  errorStrategy 'retry'
  maxRetries 5
  // cpus params.cpus
  // maxForks params.cpus
  
  input:
  file genomes from fastaGenomes
  val sketchSize
  val kmerSize  
  
  
  output:
  file "${out}.msh" into querySketch

  script:
  baseName = genomes.getBaseName()
  out = "${baseName}-${kmerSize}_kmers-${sketchSize}_sketches"
  """
  mash sketch -s ${sketchSize} -k ${kmerSize} -i ${genomes} -o $out
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
  //storeDir 'data/sketches' 

  input:
  file filesList from sketchesFilenameToPaste
  val sketchSize
  val kmerSize
  
  output:
  file "${out}.msh" into genomeSketches
  
  script:
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
  tag { query }
  publishDir 'result'

  input:
  file sketchesDb from allVsAllQuery
  file query from sketchesFilenameToDist
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  

  
  output:
  file out into allVsAllDistances

  script:
  baseName = sketchesDb.getBaseName()
  out = "${baseName}-distance.tab"
  """
  mash dist -v $pvalueThreshold -d $distanceThreshold ${sketchesDb} -l ${query} > $out
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
  val pvalueThreshold
  val distanceThreshold

  
  output:
  file out into queryDistanceResult
  
  script:
  baseName = querySketch.getBaseName()
  out      = "${baseName}-distance.tab"
  """
  mash dist -v $pvalueThreshold -d $distanceThreshold ${sketches} -l ${querySketch} > $out
  """
  
}



process filterEdges {
  //publishDir 'result'

  input:
  file dist from allVsAllDistances
  file script from filterGraphScript
  val pvalueThreshold
  val distanceThreshold


  output:
  file "${out}" into filteredDistance, filteredEdges

  script:
  baseName = dist.getBaseName()
  out = "${baseName}-${distanceThreshold}-${pvalueThreshold}.tab"
  """
  perl $script $dist ${distanceThreshold} ${pvalueThreshold} > $out
  """

}

process extractAnnotation {
  //publishDir 'result'
  
  input:
  file dist from filteredDistance

  output:
  file "$out" into annotations

  script:
  out = "annotations.tab"

  """
  mysql --max_allowed-packet=1G -ABqr pkgdb_dev -e \
    \" SELECT o.O_id, o.O_Strain, o.O_name, t.name_txt, t.rank, t.tax_id  \
       FROM   Organism o INNER JOIN O_Taxonomy t USING (O_id)
       WHERE  rank = 'species' OR rank = 'genus' OR rank = 'family' OR rank = 'order' OR rank = 'class' OR rank = 'phylum' \" >  ${out}

  """
 }


process prepareSilixInput {
  
  //  publishDir 'result'
  
  input:
  file edgeFile from filteredEdges
  
  
  output:
  file "${out}" into edgesFile
  
  script:
  base = edgeFile.getBaseName()
  out = "${base}-edges.tab"
  """
  tail -n +2 ${edgeFile} | cut -d\$'\t' -f1,2 > ${out}
  """

}

/*
* Get the num of fasta
*/
numOfFasta = countFasta.count()

//numOfFasta.subscribe {println it}


process silixx {
  
  validExitStatus 0,1
  
  input:
  file edges from edgesFile
  val num from numOfFasta

  output:
  file "$out" into silixClusterFile

  script:
  baseName = edges.getBaseName()
  out = "${baseName}.silix"
  """
  silixx $num $edges > $out
  """
  

}

process addAnnotation {

  input:
  file silixRes from silixClusterFile
  file anno     from annotations
  file script from addAnnotationScript

  output:
  file "$out" into annotatedSilixClusterFile, annotatedSilixCluster

  script:
  base = silixRes.getBaseName()
  out = "${base}-annotated.silix"
  """
  perl $script $anno $silixRes > $out
  """


}

process extractCluster {

  input:
  file multipleCluster from annotatedSilixClusterFile
  file script from extractClusterScript

  output:
  file "CL*.tab" into clusterFiles
  
  script:
  """
  perl $script $multipleCluster
  """

}


process calculateClusterIntraStat {
  publishDir 'result'
  
  input:
  file cluster from annotatedSilixCluster
  file script from calculateClusterIntraStatScript

  output:
  file "*rank.json" into rankStats
  file "*cluster.json" into clusterStats
  file "$cluster" into clu
  
  script:
  base = cluster.getBaseName()
  out = "${base}-stat"
  """
  perl $script $cluster $out
  """
}


process createJsonData {
  
  publishDir 'result', mode: 'copy'
  
  input:
  file rankStats
  file clusterStats
  val pvalueThreshold  
  val distanceThreshold
  val sketchSize       
  val kmerSize
  
  

  output:
  file "$baseName" into data
  

  script:
  baseName = "${kmerSize}-${sketchSize}-${distanceThreshold}-${pvalueThreshold}-data.js"
  """
  echo 'var rawClusterData = ' | cat - $clusterStats > clusterData
  echo -e \";\n var rawRankData = \" | cat - $rankStats > rankData
  cat clusterData rankData > $baseName
  echo -e \";\n\" >> $baseName
  echo -e 'var parametersData = {'pvalue':${pvalueThreshold},distance:${distanceThreshold},kmer:${kmerSize},sketch:${sketchSize}};' >> $baseName
  """
  

}

// process htmlReport {

  
// }



workflow.onComplete {
  println "Pipeline execution summary"
  println "---------------------------"
  println "Cmd line    : $workflow.commandLine"   
  println "Completed at: ${workflow.complete}"
  println "Duration    : ${workflow.duration}"
  println "Success     : ${workflow.success}"
  println "workDir     : ${workflow.workDir}"
  println "exit status : ${workflow.exitStatus}"
  println "Error report: ${workflow.errorReport ?: '-'}"
}
