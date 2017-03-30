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
params.bsTree = 200
params.bsExtractDstanceMatrix = 100
params.bsSketches = 500

// minSizeCluster = [0,1,5,10,15,20,25,50,100,250]
minSizeCluster = [0,1,5,10,15,20]

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
calculateSplitJoin = Channel.value(file("${params.scripts}/getSJIndex.R"))
GetRandIndexPro = Channel.value(file("${params.scripts}/getRandIndexProgenome.R"))
CalculateRandIndexTaxa = Channel.value(file("${params.scripts}/calculateRandIndexTaxa.R"))
PlotClusteringMetrics = Channel.value(file("${params.scripts}/rand-index-plot.R"))
GetTaxonomy     = Channel.value(file("${params.scripts}/getTaxonomy.pl"))
RenumberCluster = Channel.value(file("${params.scripts}/renumber-cluster.pl"))
CalculateVariationInformation = Channel.value(file("${params.scripts}/calculate-variation-information.jl"))
CalculateSJProgenome = Channel.value(file("${params.scripts}/calculateSJIndexProgenome.R"))
/*******
 * Visual report files
 *******/
VisualReport = Channel.value(file("${params.scripts}/visual_report"))

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
distanceThresholds = Channel.from(params.distances)

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
//   seqType == 'na' && seqSrc =~ /^microscope.*/'
  
//   output:
//   file "${filenameOut}" into genome
  
//   script:
//   filenameOut = "${oid}.fasta"
//   """
//   """
// }

process getNaOids {

  time '5m'
  
  input:
  file script from GetNaOids
  val seqType
  val seqSrc

  when:
  seqType == 'na' && seqSrc =~ /^microscope.*/


  output:
  set val(seqSrc), val(seqType), file("na-oids.txt") into NaOids

  script:
  """
  bash $script > na-oids.txt
  """
}


process getGenomes {
  publishDir "${resultDir}", mode: 'link', overwrite: true
  maxRetries 5
  time { 5.hour * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  
  input:
  file script from extractOrgSeq
  set val(seqSrc), val(seqType), file(oids) from NaOids
  val genomeDir

  when:
  seqType == 'na' && seqSrc =~ /^microscope.*/

  output:
  file "*.fna.gz" into genomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/genomes"
  """
  bash ${script} ${oids}
  """
}

// genomesInputs = Channel.empty()
// genomesInputs.mix(genome,genomes)
// //.flatten()
// .set { genomesInput}


process getAAOid {

  input:
  file script from GetOids
  val seqType
  val seqSrc

  when:
  seqType == 'aa' && seqSrc =~ /^microscope.*/


  output:
  set val(seqSrc), val(seqType), file("aa-oids.txt") into AaOids

  script:
  """
  bash $script > aa-oids.txt
  """
}


process getProteomes {

  publishDir "${resultDir}", mode: 'link', overwrite: true

  input:
  file script from extractProteome
  set val(seqSrc), val(seqType), file(oids) from AaOids
  val proteomeDir

  when:
  seqType == 'aa' && seqSrc =~ /^microscope.*/
  
  output:
  file("*.faa") into Proteomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/proteome"
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

  storeDir "${resultDir}"
  
  input:
  file progenomesRepresentative
  file script from splitProgenomes
  val seqType
  val seqSrc
  val progenomeDir
  

  when:
  seqType == 'na' && seqSrc =~ /^progenome.*/
  
  output:
  file("progenomes/*.fna.gz") into Progenomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/split-genomes"
  """
  perl $script $progenomesRepresentative progenomes
  """
  
  
}

SequencesInput = Channel.empty()
SequencesInput.mix(genomes, Proteomes, Progenomes)
.flatten()
.tap { countFasta }
.buffer(size: params.bsSketches, remainder: true)
//.subscribe {println it}
.set { SequencesInputs}

countSeq = countFasta.count()





/*******************
 * START PROCESSES *
 *******************/


process sketch {
  
  publishDir    "${resultDir}", mode: 'link', overwrite: true
  time          { 1.hour * task.attempt }
  memory        { 200.MB * task.attempt }
  errorStrategy 'retry'
  maxRetries    4
  
  input:
  file seqs from SequencesInputs
  val sketchSize
  val kmerSize
  val seqType
  val seqSrc
    
  output:
  file "*.msh" into querySketch mode flatten

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/sketch/individual"
  def cmd = ''
  def baseName
  if (seqType == "aa") {
    for( int i=0; i<seqs.size(); i++ ) {
      baseName = seqs[i].getBaseName()
      def out = "${baseName}"
      cmd += "mash sketch -a -s ${sketchSize} -k ${kmerSize} ${seqs[i]} -o $out\n"
    }
  } else {
    for( int i=0; i<seqs.size(); i++ ) {
      baseName = seqs[i].getBaseName()
      def out = "${baseName}"
      cmd += "mash sketch -s ${sketchSize} -k ${kmerSize} ${seqs[i]} -o $out\n"
    }
  }
  cmd
}



querySketch
.collectFile(storeDir: "${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/sketch" ) {file ->
  [ 'sketches-filenames.txt', file.toString() + '\n' ]
 }
.tap { sketchesFilenameToDist }
.map { it -> [pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it] }
.into { sketchesFilenameToPaste; sketchesFilenameToDistUpdate }


process paste_query_sketches_together {
  
  
  tag { filesList }
  // Do not store dir because will not redo this file if use a subset.
  publishDir "${resultDir}", mode: 'link', overwrite: true
  cache 'deep'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(filesList) from sketchesFilenameToPaste
  // val sketchSize
  // val kmerSize
  // val seqType
  // val seqSrc
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file("${out}.msh") into genomeSketches
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/sketch/concat"
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
  publishDir "${resultDir}", mode: 'link', overwrite: true
  cache 'deep'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(sketchesDb) from allVsAllQuery
  file query from sketchesFilenameToDist
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(out) into distanceMatrix, distanceMatrix2

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/mash-distance"
  baseName = sketchesDb.getBaseName()
  out = "${baseName}-distance.tab"
  suffix = "f${seqType}.gz"

  """
  mash dist -p ${task.cpus} ${sketchesDb} -l ${query} | perl -pe 's/\\.${suffix}//g' > $out
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
  set val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(querySketch) from sketchesFilenameToDistUpdate
  file sketches from updatedSketchesDB
  val pvalueThreshold
  val distanceThreshold
  // val sketchSize
  // val kmerSize  
  
  
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



distanceMatrix.first().into { DistanceMatrixValue }


process filterEdges {

  tag { "distance = ${distanceThresholds} - pvalue = ${pvalueThreshold}" }
  
  publishDir "${resultDir}", mode: 'link', overwrite: true
  

  input:
  set val(pvalueThreshold),val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(dist) from DistanceMatrixValue
  file script from filterGraphScript
  //val pvalueThreshold
  val distanceThresholds
  // val sketchSize
  // val kmerSize
  // val seqType
  // val seqSrc
  // val seqType
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(distanceThresholds), file("${out}") into filteredEdges

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${distanceThresholds}/results"
  baseName = dist.getBaseName()
  out = "${baseName}-filtered.tab"
  """
  perl $script $dist ${distanceThresholds} ${pvalueThreshold} > $out
  """

}

process extractAnnotation {
  
  storeDir "${resultDir}"
  
  input:
  val seqSrc
  val progenome_cluster from ProgenomeClusterRef
  file script from GetTaxonomy
  
  output:
  file "$out" into annotations

  script:
  out = "annotations.tab"
  resultDir = "${seqSrc}/annotations"

  if (seqSrc =~ /^microscope.*/)
  """
  mysql --max_allowed-packet=1G -ABqr pkgdb_dev -e \
    \" SELECT o.O_id, o.O_Strain, o.O_name, t.name_txt, t.rank, t.tax_id  \
       FROM   Organism o INNER JOIN O_Taxonomy t USING (O_id)
       WHERE rank IN ('species', 'genus', 'family', 'order', 'class', 'phylum') \" >  ${out}
  """
  else if (seqSrc =~ /^progenome.*/)
  """
  tail -n +2 $progenome_cluster | cut -f1 | cut -d'.' -f1 | sort -u > list-progenome-taxids.txt
  perl $script list-progenome-taxids.txt > $out
  """
  else
    error "Invalid seqSrc: ${seqSrc}"
 }


process prepareSilixInput {
  tag {"$d - ${edgeFile}"}
  //  publishDir 'result'
  time '5m'

  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edgeFile) from filteredEdges
  
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("${out}") into edgesFile
  
  script:
  base = edgeFile.getBaseName()
  out = "${base}-edges.tab"
  """
  tail -n +2 ${edgeFile} | cut -d\$'\t' -f1,2 | perl -pe 's/(\\d+\\.\\w+)\\.gz/\$1/g' > ${out}
  """

}


process silixx {
  tag { "$d - ${edges} - ${num}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  validExitStatus 0,1
  time '5m'
  module 'silix/1.2.9'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edges) from edgesFile
  val num from countSeq
  //val pvalueThreshold

  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("$out") into silixClusterFile, silixClusterFile2, SilixClusterFilesPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results"
  baseName = edges.getBaseName()
  out = "${baseName}.silix"
  """
  silixx $num $edges | perl -pe 's/^CL//g' > $out
  """
  

}



//***********************************************************************

SilixClusterFilesPro
.spread(minSizeCluster)
// .tap {SilixClustersPerMinSize}
// .subscribe {println it}
.set {SilixClustersPerMinSize}




process extractVectorProgenome {

  tag { "$d - minSizeCluster = ${minSizeCluster}" }

  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(clusterFile), val(minSizeCluster) from SilixClustersPerMinSize
  file ProgenomeClusterRef
  // val seqSrc
  // val sketchSize
  // val kmerSize
  // val seqType

  
  when:
  seqSrc =~ /^progenome.*/

  output:
  //file "pro-mash-taxids-intersections-${minSizeCluster}.tsv" into ProMashTaxidsIntersectionNS
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file("vector-cluster-${minSizeCluster}.csv"), val('vs-progenome') into VectorProRI, VectorProVI, VectorProSJ
  //file "list-progenome-clusters-${minSizeCluster}.tsv" into No_singleton_progenome_clusters
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/cluster-vectors"
  """
  cat $clusterFile | sort -k 2,2 | tail -n +2  > mash-clusters-sort.txt
  cat $ProgenomeClusterRef  | tail -n +2 | sort -k 1,1 > pro-clusters-sort.txt
  cat mash-clusters-sort.txt | cut -f2 > mash-taxids-sort.txt
  tail -n +2 $ProgenomeClusterRef | cut -f2 | sort | uniq -c | sort -k1,1 -n | perl -ne 's/^\\s+//g;my (\$c, \$clu) = split(/\\s+/);print \$clu,\"\\n\" if \$c >= $minSizeCluster;' > list-progenome-clusters-${minSizeCluster}.tsv
  grep -wf list-progenome-clusters-${minSizeCluster}.tsv $ProgenomeClusterRef | sort -k1,1 > pro-org-clusters-sort.tsv
  cut -f1 pro-org-clusters-sort.tsv | sort > pro-taxids-sort.tsv
  comm -12 --check-order pro-taxids-sort.tsv mash-taxids-sort.txt > pro-mash-taxids-intersections-${minSizeCluster}.tsv
  join --check-order -j 1 pro-mash-taxids-intersections-${minSizeCluster}.tsv pro-clusters-sort.txt  | sort -k1,1 > pro-clusters-sort-intersection.tsv
  join --check-order -1 1 -2 2 pro-mash-taxids-intersections-${minSizeCluster}.tsv  mash-clusters-sort.txt | sort -k1,1 > mash-clusters-sort-intersection.tsv
  join --check-order -j 1 pro-clusters-sort-intersection.tsv mash-clusters-sort-intersection.tsv | cut -d \" \" -f2,3 | perl -pe 's/specI_v2_Cluster//g' > vector-cluster-${minSizeCluster}.csv
  """
}





annotations.first().into{ AnnotationsValue }

process addAnnotation {
  tag { "$d - ${silixRes}" } 

  publishDir "${resultDir}", mode: 'link', overwrite: true	

  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(silixRes) from silixClusterFile
  file anno from AnnotationsValue
  file script from addAnnotationScript
  // val pvalueThreshold
  // val sketchSize
  // val kmerSize
  // val seqType
  // val seqSrc
  
  output:
  set val(d), file(out) into annotatedSilixClusterFile
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(out) into annotatedSilixCluster, AnnotatedSilixCluster4Rand 

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results"
  base = silixRes.getBaseName()
  out = "${base}-annotated.silix"
  
  if( seqSrc =~ /^progenome.*/)
  """
  perl -pe \'s/-.*\$//\' $silixRes > tmp
  perl $script $anno tmp > $out
  """
  else 
  """
  perl $script $anno $silixRes > $out
  """
}


process extractVectorsVsRank {
  
  tag { "$d" }

  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(annotatedClusters) from AnnotatedSilixCluster4Rand
  file script from ExtractRankIndexVectors
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("vector-*.csv"), val('vs-rank') into RandIndexesVectors, VariationOfInformationVectors, SplitJoinVectors mode flatten
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/cluster-vectors"
  """
  perl $script $annotatedClusters
  """

}


VariationOfInformationVectors
.spread([0])
.map { [ it[0], it[1], it[2], it[3], it[4], it[5], it[8], it[6], it[7] ] }
.set{ VariationOfInformationVectorsPerMinSizeCluster}

VectorVI = Channel.empty()

VectorVI
.mix(VariationOfInformationVectorsPerMinSizeCluster, VectorProVI)
.set { Vector4VI }


//.set {VectorMicroViPerMinSize}


process renumberedVectorClusters {
  tag { "$d - minSizeCluster = ${minSizeCluster}" }
  
  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(vectors), val(compareType) from Vector4VI
  file script from RenumberCluster
  // val seqSrc
  // val seqType
  // val kmerSize
  // val sketchSize
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file("$out"), val(compareType) into RenumberedClusters

  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/cluster-vectors/${compareType}"
  base_name = vectors.getBaseName()
  out = "${base_name}-renumbered.tsv"
  """
  perl $script -vectors $vectors > $out
  """

}


process CalculateVariationOfInformation {

  tag { "${d} - ${minSizeCluster} - ${clusterVectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '30m'
  memory '10 GB'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(clusterVectors), val(compareType) from RenumberedClusters
  file script from CalculateVariationInformation
  // val seqSrc
  // val seqType
  // val kmerSize
  // val sketchSize
  
  output:
  set val(minSizeCluster), file("$out"), val(compareType) into VariationOfInformation
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/variation-of-information/${compareType}"
  baseName = clusterVectors.getBaseName().split("-")
  out = "variation-of-information-${baseName[1]}-${minSizeCluster}.tsv"
  """
  num_cluster_1=`cut -d ' ' -f1 $clusterVectors | sort -nu | wc -l`
  num_cluster_2=`cut -d ' ' -f2 $clusterVectors | sort -nu | wc -l`
  julia $script $clusterVectors \$num_cluster_1 \$num_cluster_2 $d > $out
  """


}

VariationOfInformation
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/variation-of-information", seed: "distance variation_of_information\n") { it ->
  baseName = it[1].getBaseName()
  compareClustering = it[2]
  ["${compareClustering}-${baseName}.tsv", it[1].text]
 }
.map { it ->
  splitBaseName = it.getBaseName().split('-')
  compareClustering = "${splitBaseName[0]}-${splitBaseName[1]}"
  [ 'variation-of-information', compareClustering, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ]
 }
.set{ VariationOfInformationProConcat }




process calculateSplitJoinTaxa {
  tag { "$d - $spVectors" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'r/3.3.1'
  
  input:
  file script from calculateSplitJoin
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(spVectors) from SplitJoinVectors
  
  output:
  set val(d), file("split-join-*.csv") into SplitJoinIndex

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/split-join"
  baseName = spVectors.getBaseName().split("-")
  taxa = baseName[1]
  """
  Rscript $script $spVectors $d $taxa
  perl -i -ne 'chomp;my @arrayToSum = split(/\\s+/); shift @arrayToSum; my \$sum; map { \$sum += \$_ } @arrayToSum;print \$_,\" \",\$sum,\"\\n\";' split-join-${taxa}.csv
  """
}

SplitJoinIndex
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/split-join", seed: "distance 1_2 2_1 sum\n") { it ->
  baseName = it[1].getBaseName().split("-")
  taxa = baseName[2]
  [ "vs-rank-split-join-${taxa}.csv", it[1].text + "\n"]
 }
.map { it -> [ 'split-join', 'vs-rank', pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set { SplitJoinVsTaxa }


process calculateRandIndexRank {
  
  tag { "$d - $randIndexVectors" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'r/3.3.1'
  
  input:
  file script from CalculateRandIndexTaxa
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(randIndexVectors), val(compareType) from RandIndexesVectors

  output:
  set val(d), file("rand-index-*.csv"), val(compareType), val(taxa) into RandIndexVsRank

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/rand-index/${compareType}"
  baseName = randIndexVectors.getBaseName().split("-")
  taxa = baseName[1]
  """
  Rscript $script $randIndexVectors $d $taxa
  """
  
}

RandIndexVsRank
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/rand-index", seed: "distance Rand HA MA FM Jaccard\n") { it ->
  compareClustering = it[2]
  taxa = it[3]
  [ "${compareClustering}-rand-indexes-${taxa}.csv", it[1].text]
 }
.map { it -> [ 'rand-index', 'vs-rank', pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set { RandIndexesVsRank }




process calculateSplitJoinVsProgenome {
  tag { "${d} - ${Vectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true

  module 'r/3.3.1'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(Vectors), val(compareType) from VectorProSJ
  file script from CalculateSJProgenome
  
  when:
  seqSrc =~ /^progenome.*/


  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(minSizeCluster), file("$out") into SplitJoinIndexPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/split-join/${compareType}"
  inputFile = Vectors.getName()
  out = "split-join-${minSizeCluster}.csv"
  """
  Rscript $script $inputFile $d $out
  perl -i -ne 'chomp;my @arrayToSum = split(/\\s+/); shift @arrayToSum; my \$sum; map { \$sum += \$_ } @arrayToSum;print \$_,\" \",\$sum,\"\\n\";' ${out}
  """

}


SplitJoinIndexPro
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/split-join/vs-progenome", seed: "distance 1_2 2_1 sum\n") { it ->
  ["vs-progenome-split-join-${it[5]}.tsv", it[6].text]
 }
.map {it -> [ 'split-join', 'vs-progenome', pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set{ SplitJoinProConcat }




process calculateRandIndexProgenome {

  tag { "${d} - ${randIndexVectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true

  module 'r/3.3.1'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(randIndexVectors), val(compareType) from VectorProRI
  file script from GetRandIndexPro
  
  when:
  seqSrc =~ /^progenome.*/


  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(minSizeCluster), file("$out") into RandIndexPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/rand-index/${compareType}"
  inputFile = randIndexVectors.getName()
  out = "rand-index-${minSizeCluster}.csv"
  """
  Rscript $script $inputFile $d $out
  """
}

RandIndexPro
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/rand-index/vs-progenome", seed: "distance Rand HA MA FM Jaccard\n") { it ->
  ["vs-progenome-rand-indexes-${it[5]}.tsv", it[6].text]
 }
.map {it -> [ 'rand-index', 'vs-progenome', pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set{ RandIndexesProConcat }



IndexesToPlot = Channel.empty()
IndexesToPlot.mix(
  RandIndexesVsRank,
  RandIndexesProConcat,
  SplitJoinProConcat,
  SplitJoinVsTaxa,
  VariationOfInformationProConcat
)
.set { AllIndexesToPlot }


process plotIndexes {
  
  tag { Indexes }   
  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '5m'
  
  module 'r/3.3.1'
  
  input:
  set val(indexType), val(comparaisonClustering), val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(Indexes) from AllIndexesToPlot
  file script from PlotClusteringMetrics
  
  output:
  file "${out}-plot.pdf" into Plots
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${indexType}/${comparaisonClustering}/plot"
  out = Indexes.getBaseName()
  """
  Rscript $script $Indexes ${out}-plot.pdf
  """
  
}


/*

process plotVariationInformation {

  tag { variation_of_information }   
  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '5m'
  
  module 'r/3.3.1'
  
  input:
  set val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(variation_of_information) from VariationOfInformationProConcat
  file script from PlotClusteringMetrics
  // val seqSrc
  // val seqType
  // val kmerSize
  // val sketchSize


  output:
  file "${out}-plot.pdf" into VI_Plots

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/variation-of-information/plot"
  out = variation_of_information.getBaseName()
  """
  Rscript $script $variation_of_information ${out}-plot.pdf
  """
  
}

*/
distanceMatrix2.first().into{ Distancematrix2Value }
//annotatedSilixClusterFile.first().into{ AnnotatedSilixClusterFileValue }



//*******************************************************

process extractGraph {

  tag { "${d} - ${edges}" } 
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  set val(d), file(dico) from annotatedSilixClusterFile
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(edges) from Distancematrix2Value
  file script from extractClusterScript
  // val pvalueThreshold
  // val sketchSize
  // val kmerSize  
  // val seqType
  // val seqSrc
  
  output:
  file "*-nodes.tab" into nodes mode flatten
  file "*-edges.tab" into edges mode flatten
  //val d into DistanceExtractGraph
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results/graph"
  """
  perl $script $dico $edges ${d}
  """

}


phase_nodes = Channel.create()
phase_edges = Channel.create()
phase_d_extract_cluster = Channel.create()

nodes
.phase(edges) {it ->
  def split_name = it.baseName.split('-')
  return split_name[0] + split_name[1].toInteger()
 }
 .separate(phase_d_extract_cluster, phase_nodes, phase_edges) { it ->
   //println it
   def split_name = it[0].baseName.split('-');
   [ split_name[0], it[0], it[1] ]
  }
 
phase_nodes
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_nodes}

phase_edges
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_edges}

phase_d_extract_cluster
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_d_extract_cluster}


process extractDistanceMatrix {
  //tag { d }
  echo true
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  time '4h'

  
  input:
  //val d from D1
  file nodes from buf_nodes
  file edges from buf_edges
  val d from buf_d_extract_cluster
  file script from extractDistance
  
  output:
  file "*-distance-matrix.json" into ClusterDistanceMatrix mode flatten
  file "*-taxa.json" into ClusterTaxa mode flatten
  
  script:
  assert nodes.size() == edges.size()
  assert nodes.size() == d.size()
  
  def cmd = ''
  for( int i=0; i<nodes.size(); i++ ) {
    cmd += "perl $script ${nodes[i]} ${edges[i]} ${d[i]}\n"
  } 
  cmd
  
}



phase_distance_matrix   = Channel.create()
phase_taxa              = Channel.create()
phase_d_distance_matrix = Channel.create() 


ClusterDistanceMatrix
.phase(ClusterTaxa) {it ->
  def split_name = it.baseName.split('-')
  return split_name[0] + split_name[1].toInteger()
 }
 .separate(phase_d_distance_matrix, phase_distance_matrix, phase_taxa) { it ->
   def split_name = it[0].baseName.split('-');
   [ split_name[0], it[0], it[1],  seqType.value ]
  }

phase_distance_matrix
.buffer( size: params.bsTree, remainder: true )
.set {buf_distance_matrix}

phase_taxa
.buffer( size: params.bsTree, remainder: true )
.set {buf_taxa}

phase_d_distance_matrix
.buffer( size: params.bsTree, remainder: true )
.set {buf_d_nj_tree}



process calculateNJTree {

  //publishDir "${resultDir}", mode: 'link', overwrite: true
   time { 3.hour * task.attempt }
   memory { 3.GB * task.attempt }
   errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
   
  // module 'Mash/1.1.1'
  maxRetries 4

  input:
  file script   from nj
  val d         from buf_d_nj_tree
  file distance from buf_distance_matrix
  file taxa     from buf_taxa
  //val pvalueThreshold
  val sketchSize
  val kmerSize
  val seqType
  val seqSrc

  output:
  file "*-tree.json" into JsonTrees mode flatten
  file "*-tree.nwk" into NewickTrees mode flatten
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/results/trees"
  assert d.size() == distance.size()
  assert d.size() == taxa.size()
  def cmd = ''
  def out = ''
  def split_name = ''
  for (int i=0; i<distance.size(); i++) {
    split_name = distance[i].baseName.split('-')
    out = "${split_name[0]}-${split_name[1]}-tree"
    cmd += "node --max_old_space_size=3072 $script ${distance[i]} ${taxa[i]} ${out}\n"
  }
  cmd
}

JsonTrees
.subscribe onNext: {it ->
  def f = file(it)
  def split_base_name = f.getBaseName().split('-')
  def d = split_base_name[0]
  def resDirStr = "${params.seqSrc}/${params.seqType}/${params.kmerSize}-${params.sketchSize}/${d}/results/trees/json"
  def resDir = file(resDirStr)
  resDir.mkdirs()
  f.mklink(resDirStr+'/'+split_base_name[1]+'-'+split_base_name[2]+'.json', hard:true, overwrite: true)
 }, onComplete: {println 'Json trees copied'}


NewickTrees
.subscribe onNext: {it ->
  def f = file(it)
  def split_base_name = f.getBaseName().split('-')
  def d = split_base_name[0]
  def resDirStr = "${params.seqSrc}/${params.seqType}/${params.kmerSize}-${params.sketchSize}/${d}/results/trees/newick"
  def resDir = file(resDirStr)
  resDir.mkdirs()
  def out = resDirStr+'/'+split_base_name[1]+'-'+split_base_name[2]+'.nwk'
  f.mklink(out, hard:true, overwrite: true)
 }, onComplete: {println 'Newick trees copied'}



process calculateClusterIntraStat {

  tag { "${d} - ${cluster}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(cluster) from annotatedSilixCluster
  file script from calculateClusterIntraStatScript
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("*rank.json"), file("*cluster.json") into Stats
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}/results"
  base = cluster.getBaseName()
  out = "${base}-stat"
  """
  perl $script $cluster $out
  """
}


process createJsonData {

  tag { "$d"}
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(rankStats), file(clusterStats) from Stats

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("$baseName") into Data, DataVisual
  

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}"
  baseName = "data.js"
  """
  echo 'var rawClusterData = ' | cat - $clusterStats > clusterData
  echo -e \";\n var rawRankData = \" | cat - $rankStats > rankData
  cat clusterData rankData > $baseName
  echo -e \";\n\" >> $baseName
  echo -e 'var parametersData = {'pvalue':${pvalueThreshold},distance:${d},kmer:${kmerSize},sketch:${sketchSize}};' >> $baseName
  """
  

}




process addAnalysisParamstoDb {
  
  input:
  file script from existsRecord
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(data) from Data
  
  when:
  seqSrc =~ /^microscope.*/
  
  output:
  stdout mash_param_id
  
  script:
  """

  mysql GO_SPE -ABNre \"INSERT INTO MASH_param (distance, pvalue, kmer_size, sketch_size, filtered_orphan_plasmid, seq_type) VALUES ($d, $pvalueThreshold, $kmerSize, $sketchSize, TRUE, \'${seqType}\');\"

  val=`mysql GO_SPE -ABNre \"
  SELECT MASH_param_id 
  FROM MASH_param 
  WHERE 
  distance = $d
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

  input:
  val paramId from mash_param_id
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(file) from silixClusterFile2

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("mash_cluster.csv") into  mashClusterFile
  
  script:
  """
  perl -ne '
      my \$param = ${paramId}; 
      chomp \$param; chomp; 
      my (\$clusterId, \$oid) = split(/\t/); 
      \$clusterId =~ s/CL//g;
      if (\$_ ne \"\") {
         print \"\$param\t\$clusterId\t\$oid\n\";
      }' $file > mash_cluster.csv
  """

}


process loadClusterFileToDB {
  tag { "$d - ${mashClusterTab}" }
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(mashClusterTab) from mashClusterFile

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d) into ClusterLoadDB
  
  script:
  """
  loadFileToMySQLDB.sh $mashClusterTab GO_SPE MASH_cluster '\t' '\n'
  """
  
}


process setUpVisualReport {

  tag { "$d" }
  publishDir "${resultDir}", mode: 'link', overwrite: true

  input:
  file VisualReport
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d) from DataVisual

  output:
  file "visual_report" into VisualReportOut
  
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${d}"
  """
  echo \"Ok\"
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
