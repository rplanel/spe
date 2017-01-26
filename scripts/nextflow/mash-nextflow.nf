#!/usr/bin/env nextflow


println "Project  : $workflow.projectDir"
println "Cmd line : $workflow.commandLine"
println "Work dir : $workflow.workDir"
println "Profile  : $workflow.profile"
println "scripts  : $params.scripts"
println "DataDir  : $params.dataDir"


/*
* WORKFLOW PARAMETERS
* These default parameters will be overwrite by user input:
* nextflow run mash-nextflow.nf --query /path/to/file --chunksize 10
*/
//params.query
params.sketches = null
//params.genomes
params.oid = null
params.cpus
params.pvalue
params.distance
params.sketchSize
params.kmerSize
params.seqType
params.progenome = null
params.progenomeClusters = null
params.seqSrc
params.scripts


/***********
 * SCRIPTS *
 ***********/
extractOrgSeq    = Channel.value(file("${params.scripts}/extractOrgSeq.sh"))
extractProteome  = Channel.value(file("${params.scripts}/extractProteome.sh"))
GetOids          = Channel.value(file("${params.scripts}/getOids.sh"))
GetNaOids          = Channel.value(file("${params.scripts}/getOidsNa.sh"))
filterGraphScript    = Channel.value(file("${params.scripts}/filterGraph.pl"))
addAnnotationScript  = Channel.value(file("${params.scripts}/addAnnotation.pl"))
extractClusterScript = Channel.value(file("${params.scripts}/extractCluster.pl"))
extractDistance      = Channel.value(file("${params.scripts}/extractClusterDistanceMatrix.pl"))
calculateClusterIntraStatScript = Channel.value(file("${params.scripts}/calculateClusterIntraStat.pl"))
nj = Channel.value(file("${params.scripts}/calculate-nj-tree.js"))
existsRecord          = Channel.value(file("${params.scripts}/existsRecord.sh"))
splitProgenomes     = Channel.value(file("${params.scripts}/splitProgenomes.pl"))
ExtractRankIndexVectors     = Channel.value(file("${params.scripts}/extractClusters4RandIndex.pl"))
GetRandIndexPro = Channel.value(file("${params.scripts}/getRandIndexProgenome.R"))
GetRandIndexMicro = Channel.value(file("${params.scripts}/getRandIndexMicroscope.R"))


/*******
 * Visual report files
 *******/
VisualReport = Channel.value(file("${params.scripts}/visual_report"))
// // semantic dir
// Semantic = Channel.value(file("${visual_report_dir}/semantic"))
// // node_modules
// NodeModules = Channel.value(file("${visual_report_dir}/"))
// // src dir
// JsSrc= Channel.value(file("${visual_report_dir}/"))
// // elm.js
// ElmJs = Channel.value(file("${visual_report_dir}/"))
// // index.js
// Index.js = Channel.value(file("${visual_report_dir}/"))
// // mashTree.js
// MashTree.js = Channel.value(file("${visual_report_dir}/"))
// // tree.js
// Tree.js = Channel.value(file("${visual_report_dir}/"))

/********
 * Files
 ********/
//scripts        = Channel.value(file(params.scripts))
nextflowConfig = Channel.value(file("${params.scripts}/nextflow/nextflow-aa-na.config"))
progenomesRepresentative = Channel.value(file("${params.progenome}"))
ProgenomeClusterRef      = Channel.value(file("${params.progenomeClusters}"))

/******
 * StoreDir
 */
dataDir        = Channel.value("${params.dataDir}")
proteomeDir    = Channel.value("${params.dataDir}/proteome")
genomeDir      = Channel.value("${params.dataDir}/genome")
progenomeDir   = Channel.value("${params.dataDir}/progenome/genome-split")


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




distanceThresholds = Channel.from(0.01, 0.02, 0.03, 0.04)



oid = Channel.empty()
//query = Channel.empty()

if (params.oid != null) {
  oid = Channel.value(params.oid)
}

// process getGenome {
//   tag { oid }
  
//   storeDir { genomeDir }
  
//   input:
//   val oid
//   val dataDir
//   val seqType
//   val seqSrc
//   val genomeDir
  

//   when:
//   seqType == 'na' && seqSrc == 'microscope'
  
//   output:
//   file "${filenameOut}" into genome
  
//   script:
//   filenameOut = "${oid}.fasta"
//   """
//   """
// }

process getNaOids {

  input:
  file script from GetNaOids
  val seqType
  val seqSrc

  when:
  seqType == 'na' && seqSrc == 'microscope'


  output:
  file "na-oids.txt" into NaOids

  script:
  """
  bash $script > na-oids.txt
  """
}


process getGenomes {
  storeDir { genomeDir }

  
  input:
  file script from extractOrgSeq
  file oids from NaOids
  val dataDir
  val seqType
  val seqSrc
  
  val genomeDir

  when:
  seqType == 'na' && seqSrc == 'microscope'

  output:
  file "*.fna.gz" into genomes
  
  script:
  """
  bash ${script} ${oids}
  """
}

// genomesInputs = Channel.empty()
// genomesInputs.mix(genome,genomes)
// //.flatten()
// .set { genomesInput}


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

  storeDir { progenomeDir }
  
  input:
  file progenomesRepresentative
  file script from splitProgenomes
  val seqType
  val seqSrc
  val progenomeDir
  

  when:
  seqType == 'na' && seqSrc == 'progenome'
  
  output:
  file "progenomes/*.fna.gz" into Progenomes
  
  script:
  """
  perl $script $progenomesRepresentative progenomes
  """
  
  
}

SequencesInput = Channel.empty()
SequencesInput.mix(genomes, Proteomes, Progenomes)
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
  time { 30.second * task.attempt }
  memory { 200.MB * task.attempt }
  errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
  queue 'normal'
  
  // module 'Mash/1.1.1'
  maxRetries 4
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
  suffix = "f${seqType}.gz"
    // mash dist -v $pvalueThreshold -d $distanceThreshold ${sketchesDb} -l ${query} > $out
  """
  mash dist ${sketchesDb} -l ${query} | perl -pe 's/\\.${suffix}//g' > $out
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
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
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
  
  publishDir "${resultDir}", mode: 'link', overwrite: true


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
  time '5m'

  
  input:
  file edgeFile from filteredEdges
  
  
  output:
  file "${out}" into edgesFile
  
  script:
  base = edgeFile.getBaseName()
  out = "${base}-edges.tab"
  """
  tail -n +2 ${edgeFile} | cut -d\$'\t' -f1,2 | perl -pe 's/(\\d+\\.\\w+)\\.gz/\$1/g' > ${out}
  """

}


//numOfFasta.subscribe {println it}


process silixx {
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  validExitStatus 0,1
  time '5m'
  module 'silix/1.2.9'
  
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
  file "$out" into silixClusterFile, silixClusterFile2, SilixClusterFilesPro

  script:
  resultDir = "results"
  baseName = edges.getBaseName()
  out = "${baseName}.silix"
  """
  silixx $num $edges | perl -pe 's/^CL//g' > $out
  """
  

}


process extractRandIndexVectorProgenome {

  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  file SilixClusterFilesPro
  file ProgenomeClusterRef
  val seqSrc
  
  
  when:
  seqSrc == 'progenome'
    
  output:
  file "pro-mash-taxids-intersections.txt" into InterTaxids
  file "mash-clusters-sort.txt" into MashClustersSort
  file "pro-clusters-sort.txt" into ProClusters
  file "pro-clusters-sort-intersection.csv" into ProClustersInter
  file "vector-rand-index.csv" into RandIndexVectorPro
  file "mash-taxids-sort.txt" into MashTaxidsSort
  
  script:
  resultDir = "results/rand-index-vectors"
  """
  cat $ProgenomeClusterRef  | tail -n +2 | sort -k 1,1 > pro-clusters-sort.txt
  cat pro-clusters-sort.txt | cut -f1 > pro-taxids-sort.txt
  cat $SilixClusterFilesPro | sort -k 2,2 | tail -n +2  > mash-clusters-sort.txt
  cat mash-clusters-sort.txt | cut -f2 > mash-taxids-sort.txt
  comm -12 --check-order pro-taxids-sort.txt mash-taxids-sort.txt > pro-mash-taxids-intersections.txt

  join --check-order -j 1 pro-mash-taxids-intersections.txt pro-clusters-sort.txt | sort -k1,1 > pro-clusters-sort-intersection.csv
  join --check-order -1 1 -2 2 pro-mash-taxids-intersections.txt mash-clusters-sort.txt  | sort -k1,1 > mash-clusters-sort-intersection.csv
  join --check-order -j 1 mash-clusters-sort-intersection.csv pro-clusters-sort-intersection.csv | cut -d \" \" -f2,3 | perl -pe 's/specI_v2_Cluster//g' > vector-rand-index.csv
  """
}


process extractRandIndexVectorNoSingletonProgenome {
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  file MashClustersSort
  file ProClusters
  file ProgenomeClusterRef
  file MashTaxidsSort
  val seqSrc
  
  
  when:
  seqSrc == 'progenome'

  output:
  file "pro-mash-taxids-intersections-no-singleton.tsv" into ProMashTaxidsIntersectionNS
  file "vector-rand-index-no-singleton.csv" into RandIndexVectorProNS
  file "list-no-singleton-progenome-clusters.tsv" into No_singleton_progenome_clusters
  
  script:
  resultDir = "results/rand-index-vectors"
  """
  tail -n +2 $ProgenomeClusterRef | cut -f2 | sort | uniq -d > list-no-singleton-progenome-clusters.tsv
  grep -wf list-no-singleton-progenome-clusters.tsv $ProgenomeClusterRef | sort -k1,1 > pro-org-clusters-sort-no-singleton.tsv
  cut -f1 pro-org-clusters-sort-no-singleton.tsv | sort > pro-taxids-sort-no-singleton.tsv
  comm -12 --check-order pro-taxids-sort-no-singleton.tsv $MashTaxidsSort > pro-mash-taxids-intersections-no-singleton.tsv
  join --check-order -j 1 pro-mash-taxids-intersections-no-singleton.tsv pro-clusters-sort.txt| sort -k1,1 > pro-clusters-sort-intersection-no-singleton.tsv
  join --check-order -1 1 -2 2 pro-mash-taxids-intersections-no-singleton.tsv $MashClustersSort | sort -k1,1 > mash-clusters-sort-intersection-no-singleton.tsv
  join --check-order -j 1 pro-clusters-sort-intersection-no-singleton.tsv mash-clusters-sort-intersection-no-singleton.tsv | cut -d \" \" -f2,3 | perl -pe 's/specI_v2_Cluster//g' > vector-rand-index-no-singleton.csv
  """

  
}


process addAnnotation {

  publishDir "${resultDir}", mode: 'link', overwrite: true	

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
  val seqSrc
  
  output:
  file "$out" into annotatedSilixClusterFile, annotatedSilixCluster, AnnotatedSilixCluster4Rand 

  script:
  resultDir = "results"
  base = silixRes.getBaseName()
  out = "${base}-annotated.silix"
  
  if( seqSrc == 'progenome')
  """
  perl -pe \'s/-.*\$//\' $silixRes > tmp
  perl $script $anno tmp > $out
  """
  else 
  """
  perl $script $anno $silixRes > $out
  """
}


process extractRandIndexVector {

  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  file AnnotatedSilixCluster4Rand
  file script from ExtractRankIndexVectors
  val seqSrc
  
  when:
  seqSrc == 'microscope'
  
  output:
  file "vector-rand-index-*.csv" into RandIndexesVectors mode flatten
  
  script:
  resultDir = "results/rand-index-vectors"
  """
  perl $script $AnnotatedSilixCluster4Rand
  """

}





process extractGraph {
  
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  
  
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
  file "*-nodes.tab" into nodes mode flatten
  file "*-edges.tab" into edges mode flatten
  
  script:
  resultDir = "results/graph"
  """
  perl $script $dico $edges
  """

}



nodes
.phase(edges) {file ->

  def split_name = file.baseName.split('-')
  return split_name[0].toInteger()
  // (m) = (file.baseName =~ /(\d+)/)[0]
  // return m
 }
.set { tupleGraph }


process extractClusterDistanceMatrix {
  tag { "${nodes} - ${edges}" }
  queue 'normal'
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time { 30.minute * task.attempt }
  memory { 4.GB * task.attempt }
  errorStrategy { (task.exitStatus == 140 || task.exitStatus == 143) ? 'retry' : 'terminate' }
  maxRetries 3
  
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
  file "*-distance-matrix.json" into ClusterDistanceMatrix
  file "*-taxa.json" into taxa

  script:
  resultDir = "results/distance-matrices"

  """
  perl $script $nodes $edges
  """

}

ClusterDistanceMatrix
.phase(taxa) { file ->
  // 005879-distance-matrix.json
  def split_name = file.baseName.split('-')
  return split_name[0].toInteger()
 }
// .tap {tupleDistance}
// .subscribe { println it }
.set { tupleDistance }


process calculateNJTree {
   publishDir "${resultDir}", mode: 'link', overwrite: true

   tag { "${distance} - ${taxa}" }
   queue 'normal'
   time { 2.hour * task.attempt }
   memory { 3.GB * task.attempt }
   errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
   queue 'normal'
   
  // module 'Mash/1.1.1'
  maxRetries 4


   
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
  file "*-tree.json" into trees
  
  
  script:
  resultDir = "results/trees"
  (clusterId) = (distance =~ /(\d+)/ )[0]
  out = "${clusterId}-tree.json"
  
  """
  node --max_old_space_size=3072 $script $distance $taxa $out
  """
  
}


process calculateClusterIntraStat {
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
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
  
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
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
  file "$baseName" into data,dataVisual
  

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


process setUpVisualReport {
  
  publishDir "./", mode: 'link', overwrite: true

  input:
  file VisualReport


  output:
  file "visual_report" into VisualReportOut

  script:
  """
  echo \"Ok\"
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
  val seqSrc
  
  when:
  seqSrc == 'microscope'
  
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

process calculateRandIndexMicroscope {
  tag { RandIndexesVectors }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'r/3.3.1'
  
  input:
  file script from GetRandIndexMicro
  file RandIndexesVectors
  val distanceThreshold
  val seqSrc
  
  when:
  seqSrc == 'microscope'

  output:
  file "rand-index-*.csv" into RandIndexMicro

  script:
  resultDir = "results/rand-index-vectors"
  baseName = RandIndexesVectors.getBaseName().split("-")
  taxa = baseName[3]
  """
  Rscript $script $RandIndexesVectors $distanceThreshold $taxa
  """
  
}


RandIndexVectorPro
.mix(RandIndexVectorProNS)
.into {RandIndexVectorsPro}



process calculateRandIndexProgenome {

  tag {RandIndexVectorsPro}
  publishDir "${resultDir}", mode: 'link', overwrite: true

  module 'r/3.3.1'
  
  input:
  file RandIndexVectorsPro
  file script from GetRandIndexPro
  val seqSrc
  val distanceThreshold
  
  
  when:
  seqSrc == 'progenome'


  output:
  file "$out" into RandIndexPro

  script:
  resultDir = "results/rand-index-vectors"
  inputFile = RandIndexVectorsPro.getName()
  baseName = RandIndexVectorsPro.getBaseName().split("-")
  out = baseName[1..-1].join('-') + ".csv"
  """
  Rscript $script $inputFile $distanceThreshold $out
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
