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
params.numOfGenomes
params.oid
params.cpus
params.pvalue
params.distance
params.sketchSize
params.kmerSize
// params.scripts
params.data
params.work


println params.scripts

sketchesOutName = "sketches-db"


/*
 * SCRIPTS
 */
extractOrgSeq        = Channel.value(file("${params.scripts}/extractOrgSeq.sh"))
mergeFastaScript     = Channel.value(file("${params.scripts}/mergeGenomes.pl"))
splitFastaScript     = Channel.value(file("${params.scripts}/splitFasta.pl"))
filterGraphScript    = Channel.value(file("${params.scripts}/filterGraph.pl"))
addAnnotationScript  = Channel.value(file("${params.scripts}/addAnnotation.pl"))
extractClusterScript = Channel.value(file("${params.scripts}/extractCluster.pl"))
extractDistance      = Channel.value(file("${params.scripts}/extractClusterDistanceMatrix.pl"))
calculateClusterIntraStatScript = Channel.value(file("${params.scripts}/calculateClusterIntraStat.pl"))
nj = Channel.value(file("${params.scripts}/calculate-nj-tree.js"))
existsRecord          = Channel.value(file("${params.scripts}/existsRecord.sh"))

indexHtml  = Channel.value(file("${params.scripts}/visual_report/index.html"))
indexJs    = Channel.value(file("${params.scripts}/visual_report/index.js"))
piechart   = Channel.value(file("${params.scripts}/visual_report/piechart.js"))
histogram  = Channel.value(file("${params.scripts}/visual_report/histogram.js"))
parameters = Channel.value(file("${params.scripts}/visual_report/parameters.js"))


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
  file script from extractOrgSeq

  output:
  file "*.fna" into genomes

  // strtofastaudf(O_id,IF(C_id IS NULL,S_string,gotonucudf(S_string, C_begin, C_end, '+1'))) \
  
  script:
  if (numOfGenomes == 'all')
    """
    bash ${script}
    """
  else
    """
    mysql  --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
    \"SELECT strtofastaudf(O_id,IF(C_id IS NULL,S_string,gotonucudf(S_string, C_begin, C_end, '+1'))) \
     FROM Organism 
     INNER JOIN Replicon USING(O_id)
     INNER JOIN Sequence USING(R_id) 
     INNER JOIN Sequence_String USING(S_id)
     LEFT JOIN Contig USING(S_id) 
     WHERE S_status = 'inProduction' LIMIT ${numOfGenomes};\" \
     | awk '/^>/{ Oid=\$1; sub(\">\",\"\",Oid); fileout=Oid\".fna\"} {print \$0 > fileout}'
    """
}






genomesInputs = Channel.empty()
//genomesInput = Channel.create()
genomesInputs.mix(genome,genomes)
//.toList()
.flatten()
.tap { countFasta }
//.subscribe { println it }
.set { genomesInput}

//genomesInput = Channel.empty()

/*

process merge_same_organism {
  tag { g }
  storeDir 'data/genomes'
  

  input:
  each g from genomesInput 
  file mergeFastaScript
  file script from splitFastaScript
  
  output:
  file "${outdir}/*.fasta" into countFasta, fastaGenomes mode flatten

  script:
  baseName = g.getBaseName()
  out      = "${baseName}.merged.fasta"
  outdir = "per_oid"
  f = file("$outdir")
  f.mkdir()
  """
  perl ${mergeFastaScript} ${g} ${out}
  perl ${script} ${out} ${outdir}
  rm -rf ${out}
  """
}
*/


/*
process splitFasta {
  tag { mergedGenomes }
  storeDir 'data/genomes/fasta'
 
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

*/

/*  Calculate the sketches */


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
  
  
  output:
  file "${out}.msh" into querySketch

  script:
  storeDir = "data/sketch/${kmerSize}/${sketchSize}"
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
  storeDir 'data/sketch/paste' 
  queue 'normal'
  
  input:
  file filesList from sketchesFilenameToPaste
  val sketchSize
  val kmerSize
  val numOfGenomes
  
  output:
  file "${out}.msh" into genomeSketches
  
  script:
  out = "genome-sketches-${kmerSize}-${sketchSize}-${numOfGenomes}"
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
  storeDir "data/distance"
  
  input:
  file sketchesDb from allVsAllQuery
  file query from sketchesFilenameToDist
  val sketchSize
  val kmerSize  

  
  output:
  file out into allVsAllDistances, allVsAllDistances2

  script:
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



process filterEdges {

  tag { "distance = ${distanceThreshold} - pvalue = ${pvalueThreshold}" }
  
  publishDir { resultDir }


  input:
  file dist from allVsAllDistances
  file script from filterGraphScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  


  output:
  file "${out}" into filteredDistance, filteredEdges

  script:
  resultDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  baseName = dist.getBaseName()
  out = "${baseName}-filtered.tab"
  """
  perl $script $dist ${distanceThreshold} ${pvalueThreshold} > $out
  """

}

process extractAnnotation {
  storeDir "data/annotations"
  
  input:
  file dist from filteredDistance

  output:
  file "$out" into annotations

  script:
  out = "annotations.tab"


  // faire un in 
  """
  mysql --max_allowed-packet=1G -ABqr pkgdb_dev -e \
    \" SELECT o.O_id, o.O_Strain, o.O_name, t.name_txt, t.rank, t.tax_id  \
       FROM   Organism o INNER JOIN O_Taxonomy t USING (O_id)
       WHERE rank IN ('species', 'genus', 'family', 'order', 'class', 'phylum') \" >  ${out}

  """
 }


process prepareSilixInput {
  
  //  publishDir 'result'
  queue 'normal'
  
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
  publishDir { resDir }
  
  validExitStatus 0,1
  
  module 'silixx'
  
  input:
  file edges from edgesFile
  val num from numOfFasta
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  


  output:
  file "$out" into silixClusterFile, silixClusterFile2

  script:
  resDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  baseName = edges.getBaseName()
  out = "${baseName}.silix"
  """
  silixx $num $edges > $out
  """
  

}

process addAnnotation {
  publishDir { resDir }

  queue 'normal'
  
  input:
  file silixRes from silixClusterFile
  file anno     from annotations
  file script from addAnnotationScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  

  output:
  file "$out" into annotatedSilixClusterFile, annotatedSilixCluster

  script:
  resDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  base = silixRes.getBaseName()
  out = "${base}-annotated.silix"
  """
  perl $script $anno $silixRes > $out
  """


}

process extractGraph {
  
  publishDir { resDir }
  
  
  
  input:
  file dico from annotatedSilixClusterFile
  file edges from allVsAllDistances2
  file script from extractClusterScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  


  output:
  file "CL*-nodes.tab" into nodes mode flatten
  file "CL*-edges.tab" into edges mode flatten
  
  script:
  resDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results/graph"
  """
  perl $script $dico $edges
  """

}



nodes
.phase(edges) {file ->
  (m) = (file.baseName =~ /(CL\d+)/)[0]
  return m
 }
.set { tupleGraph }


process extractClusterDistanceMatrix {
  tag { "${nodes} - ${edges}" }
  queue 'normal'
  publishDir { resDir }
  
  input:
  file script from extractDistance
  set file(nodes), file(edges) from tupleGraph
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  


  output:
  file "CL*-distance-matrix.json" into distanceMatrix
  file "CL*-taxa.json" into taxa

  script:
  resDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results/distance-matrices"
  """
  perl $script $nodes $edges
  """

}

distanceMatrix
.phase(taxa) { file ->
  (m) = (file.baseName =~ /(CL\d+)/)[0]
  return m
 }
.set { tupleDistance }


process calculateNJTree {
   publishDir { resDir }

   tag { "${distance} - ${taxa}" }
   queue 'normal'
   
  input:
  file script from nj
  set file(distance), file(taxa) from tupleDistance
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize


  output:
  file "CL*-tree.json" into trees
  
  
  script:
  resDir =  "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results/trees"
  (clusterId) = (distance =~ /(CL\d+)/ )[0]
  out = "${clusterId}-tree.json"
  
  """
  node $script $distance $taxa $out
  """
  
}


process calculateClusterIntraStat {
  publishDir { resultDir }
  
  input:
  file cluster from annotatedSilixCluster
  file script from calculateClusterIntraStatScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  


  output:
  file "*rank.json" into rankStats
  file "*cluster.json" into clusterStats
  file "$cluster" into clu
  
  script:
  resultDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  base = cluster.getBaseName()
  out = "${base}-stat"
  """
  perl $script $cluster $out
  """
}


process createJsonData {
  
  publishDir { resultDir }
  
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
  resultDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}"
  baseName = "data.js"
  """
  echo 'var rawClusterData = ' | cat - $clusterStats > clusterData
  echo -e \";\n var rawRankData = \" | cat - $rankStats > rankData
  cat clusterData rankData > $baseName
  echo -e \";\n\" >> $baseName
  echo -e 'var parametersData = {'pvalue':${pvalueThreshold},distance:${distanceThreshold},kmer:${kmerSize},sketch:${sketchSize}};' >> $baseName
  """
  

}



process addAnalysisParamstoDb {

  queue 'normal'
  
  input:
  val pvalueThreshold  
  val distanceThreshold
  val sketchSize       
  val kmerSize
  file script from existsRecord
  file data

  output:
  stdout mash_param_id
  
  script:
  """

  mysql GO_SPE -ABNre \"INSERT INTO MASH_param (distance, pvalue, kmer_size, sketch_size, filtered_orphan_plasmid) VALUES ($distanceThreshold, $pvalueThreshold, $kmerSize, $sketchSize, TRUE);\"

  val=`mysql GO_SPE -ABNre \"
  SELECT MASH_param_id 
  FROM MASH_param 
  WHERE 
  distance = $distanceThreshold
  AND 
  pvalue = $pvalueThreshold
  AND 
  kmer_size = $kmerSize 
  AND 
  sketch_size = $sketchSize
  AND
  filtered_orphan_plasmid = TRUE;\"`

  echo \$val

  """

}


process createClusterTable {
  queue 'normal'

  input:
  val paramId from mash_param_id
  file silixClusterFile2

  output:
  file "mash_cluster.csv" into  mashClusterFile
  
  script:
  """
  perl -ne '
      my \$param = ${paramId}; 
      chomp \$param; chomp; 
      my (\$clusterId, \$oid) = split(/\t/); 
      \$clusterId =~ s/CL//g;
      if (\$_ ne \"\") {
         print \"\$param\t\$clusterId\t\$oid\n\";
      }' $silixClusterFile2 > mash_cluster.csv
  """

}


process loadClusterFileToDB {

  queue 'normal'
  
  input:
  file mashClusterFile

  output:
  val "Ok" into end
  
  script:
  """
  loadFileToMySQLDB.sh $mashClusterFile GO_SPE MASH_cluster '\t' '\n'
  """
  
}


workflow.onComplete {
  println "Pipeline execution summary"
  println "---------------------------"
  println "Cmd line    : $workflow.commandLine"   
  println "Completed at: ${workflow.complete}"
  println "Duration    : ${workflow.duration}"
  println "workDir     : ${workflow.workDir}"
  println "session id  : ${workflow.sessionId}"
  println "exit status : ${workflow.exitStatus}"
  println "Error report: ${workflow.errorReport ?: '-'}"
  println "Success     : ${workflow.success}"
}
