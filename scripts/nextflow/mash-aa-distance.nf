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
params.seqType
params.progenome
params.seqSrc
// params.scripts


/***********
 * SCRIPTS *
 ***********/
extractOrgSeq    = Channel.value(file("${params.scripts}/extractOrgSeq.sh"))
extractProteome  = Channel.value(file("${params.scripts}/extractProteome.sh"))
GetOids          = Channel.value(file("${params.scripts}/getOids.sh"))
filterGraphScript    = Channel.value(file("${params.scripts}/filterGraph.pl"))
addAnnotationScript  = Channel.value(file("${params.scripts}/addAnnotation.pl"))
extractClusterScript = Channel.value(file("${params.scripts}/extractCluster.pl"))
extractDistance      = Channel.value(file("${params.scripts}/extractClusterDistanceMatrix.pl"))
calculateClusterIntraStatScript = Channel.value(file("${params.scripts}/calculateClusterIntraStat.pl"))
nj = Channel.value(file("${params.scripts}/calculate-nj-tree.js"))
existsRecord          = Channel.value(file("${params.scripts}/existsRecord.sh"))
splitProgenomes     = Channel.value(file("${params.scripts}/splitProgenomes.pl"))

/********
 * Files
 ********/
scripts        = Channel.value(file(params.scripts))
nextflowConfig = Channel.value(file("${params.scripts}/nextflow/nextflow-aa-na.config"))
progenomesRepresentative =  Channel.value(file("${params.progenome}"))

/******
 * StoreDir
 */
dataDir        = Channel.value("${params.dataDir}")
proteomeDir    = Channel.value("${params.dataDir}/proteome")
genomeDir      = Channel.value("${params.dataDir}/genome")
progenomeDir   = Channel.value("${params.dataDir}/progenome/split")


/*
 * Values parameters
 */
pvalueThreshold   = Channel.value(params.pvalue)
distanceThreshold = Channel.value(params.distance)
sketchSize        = Channel.value(params.sketchSize)
kmerSize          = Channel.value(params.kmerSize)
seqType           = Channel.value(params.seqType)
seqSrc            = Channel.value(params.seqSrc)
//storeDir          = Channel.value("${params.dataDir}/sketch/${params.seqSrc}/${params.seqType}/${params.kmerSize}/${params.sketchSize}")

oid = Channel.empty()
//query = Channel.empty()

if (params.oid != null) {
  oid = Channel.value(params.oid)
}

process getGenome {
  tag { oid }
  
  storeDir { genomeDir }
  
  input:
  val oid
  val dataDir
  val seqType
  val seqSrc
  val genomeDir
  

  when:
  seqType == 'na' && seqSrc == 'microscope'
  
  output:
  file "${filenameOut}" into genome
  
  script:
  filenameOut = "${oid}.fasta"
  """
  """
}



process getGenomes {
  storeDir { genomeDir }

  
  input:
  file script from extractOrgSeq
  val dataDir
  val seqType
  val seqSrc
  
  val genomeDir

  when:
  seqType == 'na' && seqSrc == 'microscope'

  output:
  file "*.fna" into genomes
  
  script:
  """
  bash ${script}
  """
}

genomesInputs = Channel.empty()
genomesInputs.mix(genome,genomes)
.flatten()
.tap { countFasta }
.set { genomesInput}


process getOid {

  input:
  file script from GetOids
  val seqType
  val seqSrc

  when:
  seqType == 'aa' && seqSrc == 'microscope'


  output:
  file "oids.txt" into Oids

  script:
  """
  bash $script > oids.txt
  """
}


process getProteomes {
  storeDir { proteomeDir }
  
  input:
  file script from extractProteome
  file oids from Oids
  val proteomeDir
  val seqType
  val seqSrc

  when:
  seqType == 'aa' && seqSrc == 'microscope'
  
  output:
  file "*.faa" into Proteomes
  
  script:
  """
  bash ${script} ${oids}
  """
}
/*
Proteomes
.toList()
.set {ListProteomes}

*/


process splitProgenomes {

  storeDir {progenomeDir}
  
  input:
  file progenomesRepresentative
  file script from splitProgenomes
  val seqType
  val seqSrc
  val progenomeDir
  

  when:
  seqType == 'na' && seqSrc == 'progenome'
  
  output:
  file "progenomes/*.fna" into Progenomes
  
  script:
  """
  perl $script $progenomesRepresentative progenomes
  """
  
  
}

SequencesInput = Channel.empty()
SequencesInput.mix(genomesInput, Proteomes, Progenomes)
.flatten()
.tap { countFasta }
.set { SequencesInputs}

countSeq = countFasta.count()





/*******************
 * START PROCESSES *
 *******************/


process sketch {
  
  tag { seqs }
  storeDir { storeDir }
  errorStrategy 'retry'
  queue 'normal'
  //maxRetries 5
  // cpus params.cpus
  // maxForks params.cpus
  
  input:
  file seqs from SequencesInputs
  val dataDir
  val sketchSize
  val kmerSize
  val seqType
  val seqSrc
    
  output:
  file "${out}.msh" into querySketch

  script:

  storeDir = "${dataDir}/sketch/${seqSrc}/${seqType}/${kmerSize}/${sketchSize}"
  baseName = seqs.getBaseName()
  out = "${baseName}"
  if (seqType == "aa")
  """
  mash sketch -a -s ${sketchSize} -k ${kmerSize} ${seqs} -o $out
  """
  else
  """
  mash sketch -s ${sketchSize} -k ${kmerSize} ${seqs} -o $out
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
  val seqType
  val seqSrc
  
  output:
  file "${out}.msh" into genomeSketches
  
  script:
  storeDir = "${dataDir}/sketch/${seqSrc}/${seqType}/paste"
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
  val seqType
  val seqSrc
  
  output:
  file out into distanceMatrix, distanceMatrix2

  script:
  storeDir = "${dataDir}/distance/${seqSrc}/${seqType}"
  baseName = sketchesDb.getBaseName()
  out = "${baseName}-distance.tab"

  // mash dist -v $pvalueThreshold -d $distanceThreshold ${sketchesDb} -l ${query} > $out
  """
  mash dist ${sketchesDb} -l ${query} | perl -pe 's/\\.faa//g' > $out
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
  file dist from distanceMatrix
  file script from filterGraphScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize
  val seqType
  val dataDir


  output:
  file "${out}" into filteredDistance, filteredEdges

  script:
  resultDir = "results"
  baseName = dist.getBaseName()
  out = "${baseName}-filtered.tab"
  """
  perl $script $dist ${distanceThreshold} ${pvalueThreshold} > $out
  """

}

process extractAnnotation {
  storeDir "${dataDir}/annotations"
  
  input:
  file dist from filteredDistance
  val dataDir
  
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


//numOfFasta.subscribe {println it}


process silixx {
  publishDir { resDir }
  
  validExitStatus 0,1
  
  module 'silixx'
  
  input:
  file edges from edgesFile
  val num from countSeq
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize
  val seqType
  val dataDir


  output:
  file "$out" into silixClusterFile, silixClusterFile2

  script:
  resDir = "results"
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
  val seqType
  val dataDir

  output:
  file "$out" into annotatedSilixClusterFile, annotatedSilixCluster

  script:
  resDir = "results"
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
  file edges from distanceMatrix2
  file script from extractClusterScript
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize  
  val seqType
  val dataDir


  output:
  file "CL*-nodes.tab" into nodes mode flatten
  file "CL*-edges.tab" into edges mode flatten
  
  script:
  resDir = "results/graph"
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
  val seqType
  val dataDir


  output:
  file "CL*-distance-matrix.json" into ClusterDistanceMatrix
  file "CL*-taxa.json" into taxa

  script:
  resDir = "results/distance-matrices"

  """
  perl $script $nodes $edges
  """

}

ClusterDistanceMatrix
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
  val seqType
  val dataDir


  output:
  file "CL*-tree.json" into trees
  
  
  script:
  resDir = "results/trees"
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
  val seqType
  val dataDir



  output:
  file "*rank.json" into rankStats
  file "*cluster.json" into clusterStats
  file "$cluster" into clu
  
  script:
  resultDir = "results"
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
  val seqType
  val dataDir
  
  

  output:
  file "$baseName" into data
  

  script:
  resultDir = "./"
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
  val seqType
  
  output:
  stdout mash_param_id
  
  script:
  """

  mysql GO_SPE -ABNre \"INSERT INTO MASH_param (distance, pvalue, kmer_size, sketch_size, filtered_orphan_plasmid, seq_type) VALUES ($distanceThreshold, $pvalueThreshold, $kmerSize, $sketchSize, TRUE, \'${seqType}\');\"

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
  filtered_orphan_plasmid = TRUE
  AND 
  seq_type = \'${seqType}\';\"`

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







/*
process clusterGenomes {

  publishDir { runDir }
  cache false
  
  input:
  file script from clusterGenomes
  file scripts
  file config from nextflowConfig
  file ListProteomes
  val pvalueThreshold
  val distanceThreshold
  val sketchSize
  val kmerSize
  val dataDir
  val SeqDir from proteomeDir
  

  output:
  file ".command.out" into ClusterGenomesOut
  file "*trace*" into Trace
  file "*timeline*" into Timeline
  
  script:
  runDir = "${dataDir}/runs/aa/${kmerSize}-${sketchSize}/${pvalueThreshold}-${distanceThreshold}"
  """
  nextflow run ${script} -resume -w ${runDir}/work --sketchSize $sketchSize --kmerSize $kmerSize --pvalue $pvalueThreshold --distance $distanceThreshold --seqType aa --scripts ${scripts} --dataDir ${dataDir} -with-timeline -with-trace -c $config --cpus ${params.cpus} --seqDir $SeqDir
  """
  
}

*/
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
