-*- mode: groovy;-*-

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
params.sketches = null
//params.genomes
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
params.dicoTaxoCorrection
params.mopadGenomeDir = null
params.mopadAnnotation = null

// minSizeCluster = [0,1,5,10,15,20,25,50,100,250]
minSizeCluster = [0]

/***********
 * SCRIPTS *
 ***********/
extractOrgSeq                 = Channel.value(file("${params.scripts}/extractOrgSeq.sh"))
extractProteome               = Channel.value(file("${params.scripts}/extractProteome.sh"))
GetOids                       = Channel.value(file("${params.scripts}/getOids.sh"))
GetNaOids                     = Channel.value(file("${params.scripts}/getOidsNa.sh"))
FilterGraph                   = Channel.value(file("${params.scripts}/filterGraph.pl"))
AddAnnotation                 = Channel.value(file("${params.scripts}/addAnnotation.pl"))
ExtractCluster                = Channel.value(file("${params.scripts}/extractCluster.pl"))
extractDistance               = Channel.value(file("${params.scripts}/extractClusterDistanceMatrix.pl"))
CalculateClusterIntraStat     = Channel.value(file("${params.scripts}/calculateClusterIntraStat.pl"))
nj                            = Channel.value(file("${params.scripts}/calculate-nj-tree.js"))
existsRecord                  = Channel.value(file("${params.scripts}/existsRecord.sh"))
splitProgenomes               = Channel.value(file("${params.scripts}/splitProgenomes.pl"))
ExtractRankIndexVectors       = Channel.value(file("${params.scripts}/extractClusters4RandIndex.pl"))
calculateSplitJoin            = Channel.value(file("${params.scripts}/getSJIndex.R"))
GetRandIndexPro               = Channel.value(file("${params.scripts}/getRandIndexProgenome.R"))
CalculateRandIndexTaxa        = Channel.value(file("${params.scripts}/calculateRandIndexTaxa.R"))
PlotClusteringMetrics         = Channel.value(file("${params.scripts}/rand-index-plot.R"))
GetTaxonomy                   = Channel.value(file("${params.scripts}/getTaxonomy.pl"))
RenumberCluster               = Channel.value(file("${params.scripts}/renumber-cluster.pl"))
CalculateVariationInformation = Channel.value(file("${params.scripts}/calculate-variation-information.jl"))
CalculateSJProgenome          = Channel.value(file("${params.scripts}/calculateSJIndexProgenome.R"))
GenerateClusterTable          = Channel.value(file("${params.scripts}/silix-cluster-to-mash-cluster-table.py"))
calculateClique               = Channel.value(file("${params.scripts}/calculate-cliques.py"))
ConvertOrgToId                = Channel.value(file("${params.scripts}/convert-org-to-int-id.py"))
ReplaceCustomId               = Channel.value(file("${params.scripts}/replace-custom-id.py"))
CalculateLouvainCommunities   = Channel.value(file("${params.scripts}/calculate-louvain-communities.py"))
ConvertToInfomapIn            = Channel.value(file("${params.scripts}/convert-to-infomap-input.py"))
InfomapOutToOri               = Channel.value(file("${params.scripts}/infomap-output-to-originalid.py"))
GetDiffScript                 = Channel.value(file("${params.scripts}/get-diff-clusterging.py"))
CalculateSpecificitySensitivity = Channel.value(file("${params.scripts}/calculate-specificity-sensitivity.py"))

/*******
 * Visual report files
 *******/
VisualReport = Channel.value(file("${params.scripts}/visual_report"))

/********
 * Files
 ********/
progenomesRepresentative = Channel.value(file("${params.progenome}"))
ProgenomeClusterRef      = Channel.value(file("${params.progenomeClusters}"))
mopadAnnotations         = Channel.value(file("${params.mopadAnnotation}"))
mopadGenomes             = Channel.fromPath("${params.mopadGenomeDir}/*_contig.fa" )
DicoTaxoCorrection       = Channel.value(file("${params.dicoTaxoCorrection}"))


/*
 * Values parameters
 */
pvalueThreshold    = Channel.value(params.pvalue)
distanceThreshold  = Channel.value(params.distance)
sketchSize         = Channel.value(params.sketchSize)
kmerSize           = Channel.value(params.kmerSize)
seqType            = Channel.value(params.seqType)
seqSrc             = Channel.value(params.seqSrc)
distanceThresholds = Channel.from(params.distances)



process getNaOids {
  tag { seqSrc }
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

  // publishDir "${resultDir}", mode: 'link', overwrite: true
  storeDir "${resultDir}"
  maxRetries 5
  time { 5.hour * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  
  input:
  file script from extractOrgSeq
  set val(seqSrc), val(seqType), file(oids) from NaOids

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

  when:
  seqType == 'aa' && seqSrc =~ /^microscope.*/
  
  output:
  file("*.faa.gz") into Proteomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/proteome"
  """
  bash ${script} ${oids}
  gzip *.faa
  """
}


process splitProgenomes {

  storeDir "${resultDir}"
  
  input:
  file progenomesRepresentative
  file script from splitProgenomes
  val seqType
  val seqSrc
  

  when:
  seqSrc =~ /^progenome.*/
  
  output:
  file("progenomes/*.f${seqType}.gz") into Progenomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/split-genomes"
  """
  perl $script $progenomesRepresentative progenomes
  """
}



process getMopdadGenomes {
  tag { genome }
  storeDir "${resultDir}"
  
  input:
  file genome from mopadGenomes
  val seqType
  val seqSrc
  

  when:
  seqType == 'na' && seqSrc =~ /^mopad.*/
  
  output:
  file "${out}" into MopadGenomes
  
  script:
  resultDir = "${seqSrc}/${seqType}/genomes"
  baseName = genome.getBaseName().split('_')
  out = "${baseName[0]}.fna.gz"
  """
  gzip -c ${genome} > ${out}
  """

}


SequencesInput = Channel.empty()


SequencesInput.mix(genomes, Proteomes, Progenomes, MopadGenomes)
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
  //storeDir    "${resultDir}"
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


// Put all the sketch's path in a file
querySketch
.collectFile(storeDir: "${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/sketch" ) {file ->
  [ 'sketches-filenames.txt', file.toString() + '\n' ]
 }
.tap { sketchesFilenameToDist }.map { it ->
  [pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it]
}
.into { sketchesFilenameToPaste; sketchesFilenameToDistUpdate }


process paste_query_sketches_together {
  
  
  tag { filesList }
  // Do not store dir because will not redo this file if use a subset.
  publishDir "${resultDir}", mode: 'link', overwrite: true
  cache 'deep'
  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(filesList) from sketchesFilenameToPaste
  
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
  tag { "${query} distance=${sketchSize} kmersize=${kmerSize} $sketchesDb" } 
  time { seqSrc == 'progenome_test' ? 1.hour :  23.hour }
  //time '4h'
  cpus 1
  scratch true
  storeDir "${resultDir}"
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  cache 'deep'

  
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(sketchesDb) from allVsAllQuery
  file query from sketchesFilenameToDist
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file("${out}.gz") into distanceMatrix, distanceMatrix2, MashDistancesDico

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/mash-distance"
  baseName  = sketchesDb.getBaseName()
  out       = "${baseName}-distance.tab"
  suffix    = "f${seqType}.gz"

  """
  mash dist -p ${task.cpus} ${sketchesDb} -l ${query} | perl -pe 's/\\.${suffix}//g' > $out
  gzip $out
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
  
  output:
  file out into queryDistanceResult
  
  script:
  resultDir = "report/${kmerSize}-${sketchSize}-${pvalueThreshold}-${distanceThreshold}/results"
  baseName  = querySketch.getBaseName()
  out      = "${baseName}-${distanceThreshold}-${pvalueThreshold}-distance.tab"
  """
  mash dist -v $pvalueThreshold -d $distanceThreshold ${sketches} -l ${querySketch} > $out
  """
  
}



distanceMatrix.first().set { DistanceMatrixValue }


process filterEdges {

  tag { "distance = ${distanceThresholds} - pvalue = ${pvalueThreshold}" }
  storeDir "${resultDir}"
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  time '4h'

  input:
  set val(pvalueThreshold),val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(dist) from DistanceMatrixValue
  file script from FilterGraph
  val distanceThresholds
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(distanceThresholds), file("${out}.gz") into filteredEdges, filteredEdgesClique, filteredEdgesLouvain, filteredEdgesWLouvain, filteredEdgesInfomap

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/mash-distance"
  baseName  = dist.getBaseName().split('\\.')
  out       = "${baseName[0]}-filtered-${distanceThresholds}.tab"
  """
  perl $script $dist ${distanceThresholds} ${pvalueThreshold} > $out
  gzip ${out}
  """

}

process extractAnnotation {
  
  storeDir "${resultDir}"
  
  input:
  val seqSrc
  val progenome_cluster from ProgenomeClusterRef
  val mopad_anno from mopadAnnotations
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
  else if (seqSrc =~ /^mopad.*/)
  """
  cp ${mopad_anno} annotations.tab
  """
  else
    error "Invalid seqSrc: ${seqSrc}"
 }


process prepareSilixInput {
  tag {"$d - ${edgeFile}"}
  //  publishDir 'result'
  time '30m'

  when:
  true
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edgeFile) from filteredEdges
  
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("${out}") into edgesFile
  
  script:
  base = edgeFile.getBaseName()
  out = "${base}-edges.tab"
  """
  zcat ${edgeFile} | cut -d\$'\t' -f1,2  | perl -pe 's/(\\d+\\.\\w+)\\.gz/\$1/g' > ${out}
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
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("$out"), val('silix') into silixClusterFile, silixClusterFile2, SilixClusterFilesPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/silix/${d}/results"
  baseName = edges.getBaseName()
  out = "${baseName}.silix"
  """
  silixx $num $edges | perl -pe 's/^CL//g' > $out
  """
  

}

process clique {

  tag { "${edge} - ${d}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'python/3.5.3'
  module 'gnu/4.9.2'
  // time { seqSrc == 'progenome' ? 4.hour * task.attempt :  1.hour * task.attempt }
  // errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  // maxRetries 4

  when: 
  false

  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edge) from filteredEdgesClique
  //  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edge) from EdgesToClique
  file script from calculateClique

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("clique*.txt"), val(clusteringMethod) into CliqueClusters, CliqueClustersPro
  
  script:
  clusteringMethod = 'clique'
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/per-cluster"
  // listBaseName = edge.getBaseName().split('-')
  // clusterId = listBaseName[1]
  """
  python ${script} -e ${edge} -o clique-${d}.txt
  """
}


process louvainCommunities {
  tag {"${edges} - ${d}"}
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  storeDir "${resultDir}"
  // scratch true

  memory { task.memory * task.attempt }
  time   { task.time   * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 2
  module 'python/2.7.8'
  module 'python-louvain/0.6'
  
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edges) from filteredEdgesLouvain
  file script from CalculateLouvainCommunities

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(out), val(clusteringMethod) into LouvainClusters, LouvainClustersPro

  script:
  clusteringMethod = 'louvain_partition_0'
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results"
  baseName = edges.getBaseName()
  out = "${baseName}-louvain_clusters.tsv"
  """
  python ${script} --edges ${edges} -o ${out}
  """

}


process weightedLouvainCommunities {
  tag {"${edges} - ${d}"}
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  storeDir "${resultDir}"


  //scratch true
  memory { task.memory * task.attempt }
  time   { task.time   * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 2
  module 'python/2.7.8'
  module 'python-louvain/0.6'

  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edges) from filteredEdgesWLouvain
  file script from CalculateLouvainCommunities

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(out), val(clusteringMethod) into WLouvainClusters, WLouvainClustersPro

  script:
  clusteringMethod = 'weighted_louvain_partition_0'
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results"
  baseName = edges.getBaseName()
  out = "${baseName}-louvain_clusters.tsv"
  """
  python ${script} --edges ${edges} -o ${out} --weight
  """
  
}


process infoMap {
  tag {"${edges} - ${d}"}
  publishDir "${resultDir}", mode: 'link', overwrite: true

  memory { task.memory * task.attempt }
  time   { task.time   * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 4
  module 'python/3.5.3'

  when:
  false
  
  input:
  file convertToIn from ConvertToInfomapIn
  file convertFromOut from InfomapOutToOri
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edges) from filteredEdgesInfomap

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(out), val(clusteringMethod) into InfomapClusters, InfomapClustersPro

  
  
  script:
  //perl -ne 'if (!/^#/) {chomp; my (\$node, \$clu) = split(/\\s+/);print \"\$clu\\t\$node\\n\";}' ${clusters} > ${out}
  clusteringMethod = 'infomap'
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results"
  baseName = edges.getBaseName()
  linkList = "${clusteringMethod}-linklist"
  clusters = "${linkList}.clu"
  out = "${baseName}-infomap_clusters.tsv"
  """
  python ${convertToIn} -e ${edges} -o ${linkList}
  Infomap ${linkList} ./ -ilink-list -N 10 -u --clu -z -k
  python ${convertFromOut} -c ${clusters} -d new-to-original-id.tsv -o ${out}
  
  """


}

/*
process orgToIntId {

  tag { "${edge}" }
  
  module 'python/3.5.3'
  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edge) from filteredEdgesLouvain
  file script from ConvertOrgToId
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("*-customid.tsv") into filteredEdgesLouvainInt
  file "*-dico.tsv" into OrgDico
    
  script:
  """
  python $script -e ${edge}
  """
}
*/


/*
process calculateLouvainCommunities {
  tag {"${edge} - ${d}"}
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '2h'
  module 'python/3.5.3'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(edge) from filteredEdgesLouvainInt
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(communities), val(clusteringMethod) into LouvainClustersInt
  
  script:
  baseName = edge.getBaseName()
  clusteringMethod = 'louvain'
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/per-cluster"
  onlyEdges = "only-edges.tab"
  graph     = "graph.bin"
  graphTree = "graph.tree"
  communities = baseName + "-communities.tsv"
  """
  cut -f1,2 ${edge} | tail -n +2 > ${onlyEdges}
  louvain-convert -i ${onlyEdges} -o ${graph}
  louvain ${graph} -l -1 -v -q 0 > ${graphTree}
  level=\$((`louvain-hierarchy -n | grep 'Number of levels' | cut -d ':' -f2` - 1))
  louvain-hierarchy ${graphTree} -l \$level > ${communities}
  """
}
*/


/*
process replace_int_to_org_id {
  
  module 'python/3.5.3'
  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(communities), val(clusteringMethod) from LouvainClustersInt
  file dico from OrgDico
  file script from ReplaceCustomId

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(louvainClusters), val(clusteringMethod) into LouvainClusters
  
  script:
  baseName = communities.getBaseName()
  println baseName
  baseNameSplitted = baseName.split("-")
  
  baseNameSplitted.removeElement("customid")
  louvainClusters = baseNameSplitted.join("-") + '.tsv'
  """
  python ${script} -c ${communities} -d ${dico} -o ${out}
  """


}
*/


silixClusterFile
.mix(CliqueClusters, LouvainClusters, WLouvainClusters, InfomapClusters)
.set { ClusterFile }


//***********************************************************************


SilixClusterFilesPro
.mix(CliqueClustersPro, LouvainClustersPro, WLouvainClustersPro, InfomapClustersPro)
.spread(minSizeCluster)
// .tap {SilixClustersPerMinSize}
// .subscribe {println it}
.set {ClustersPerMinSize}




process extractVectorProgenome {

  tag { "$d - ${clusteringMethod} - minSizeCluster = ${minSizeCluster}" }

  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(clusterFile), val(clusteringMethod), val(minSizeCluster) from ClustersPerMinSize
  file ProgenomeClusterRef

  
  when:
  seqSrc =~ /^progenome.*/

  output:
  //file "pro-mash-taxids-intersections-${minSizeCluster}.tsv" into ProMashTaxidsIntersectionNS
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file("vector-cluster-${minSizeCluster}.csv"), val('vs-progenome'), val(clusteringMethod) into VectorProRI, VectorProVI, VectorProSJ
  //file "list-progenome-clusters-${minSizeCluster}.tsv" into No_singleton_progenome_clusters
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/cluster-vectors"
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





annotations.first().set { AnnotationsValue }

process addAnnotation {
  tag { "$d - ${clusteringMethod} - ${silixRes}" } 
  
  publishDir "${resultDir}", mode: 'link', overwrite: true	
  //storeDir "${resultDir}"
  
  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(silixRes), val(clusteringMethod) from ClusterFile
  file anno from AnnotationsValue
  file script from AddAnnotation
  // val pvalueThreshold
  // val sketchSize
  // val kmerSize
  // val seqType
  // val seqSrc
  
  output:
  set val(d), file(out), val(clusteringMethod) into annotatedSilixClusterFile
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(out), val(clusteringMethod) into annotatedSilixCluster, AnnotatedSilixCluster4Rand 

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results"
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
  
  tag { "$d - ${clusteringMethod}" }

  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(annotatedClusters), val(clusteringMethod) from AnnotatedSilixCluster4Rand
  file dico_taxo_correction from DicoTaxoCorrection
  file script from ExtractRankIndexVectors
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("vector-*.csv"), val('vs-rank'), val(clusteringMethod) into VectorsAnnotated, VectorsAnnotated2, VectorsAnnotated3 mode flatten
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/cluster-vectors"
  """
  perl $script $annotatedClusters ${dico_taxo_correction}
  """

}



process sensitivity_specificity {
  tag { "$d - ${vector_file} - ${clusteringMethod}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time   { task.time   * task.attempt }
  memory { task.memory * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 2

  when:
  false
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(vector_file), val(compareType), val(clusteringMethod) from VectorsAnnotated3
  file script from CalculateSpecificitySensitivity
  
  output:
  set file("${out}"), val(taxa), val(d), val(compareType), val(clusteringMethod) into SensitivitySpecificityRes

  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/sensitivity-specificity"
  base_name = vector_file.getBaseName().split('-')
  taxa = base_name[1]
  out = "${taxa}-sensitivity-specificity.tsv"
  
  """
  python ${script} --clustering $vector_file > ${out}
  """

}

SensitivitySpecificityRes
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/sensitivity-specificity" , seed: "distance\tsensitivity\tspecificity\n") { it ->
  taxa = it[1]
  distance = it[2]
  compareClustering = it[3]
  clusteringMethod  = it[4]
  ["${clusteringMethod}-${compareClustering}-${taxa}.tsv", distance + "\t" + it[0].text ]
 }


process clustering_diff {
  tag { "$d - ${vector_file} - ${clusteringMethod}" }
  
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '2h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(vector_file), val(compareType), val(clusteringMethod) from VectorsAnnotated2
  file script from GetDiffScript
  
  output:
  file out into ClusteringDiff
  
  script:
  base_name = vector_file.getBaseName()
  out = "${base_name}-diff.csv"
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/clustering-diff"
  """
  python ${script} -c $vector_file > $out
  """
  
}


process cut_vectors {

  tag { "$d - ${clusteringMethod}" }
  
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '2h'

  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(vector_file), val(compareType), val(clusteringMethod) from VectorsAnnotated

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("$out"), val(compareType), val(clusteringMethod) into RandIndexesVectors, VariationOfInformationVectors, SplitJoinVectors

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/cluster-vectors"
  base_name = vector_file.getBaseName()
  out = "${base_name}-notaxo.csv"
  """
  cut -f1,2 $vector_file > $out
  """


  

}


VariationOfInformationVectors
.spread([0])
.map { [ it[0], it[1], it[2], it[3], it[4], it[5], it[9], it[6], it[7], it[8] ] }
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
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(vectors), val(compareType), val(clusteringMethod) from Vector4VI
  file script from RenumberCluster
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file("$out"), val(compareType), val(clusteringMethod) into RenumberedClusters

  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/cluster-vectors/${compareType}"
  base_name = vectors.getBaseName()
  out = "${base_name}-renumbered.tsv"
  """
  perl $script -vectors $vectors > $out
  """

}


process variationOfInformation {

  tag { "${d} - ${minSizeCluster} - ${clusterVectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time '30m'
  memory '10 GB'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(clusterVectors), val(compareType), val(clusteringMethod) from RenumberedClusters
  file script from CalculateVariationInformation
  // val seqSrc
  // val seqType
  // val kmerSize
  // val sketchSize
  
  output:
  set val(minSizeCluster), file("$out"), val(compareType), val(clusteringMethod) into VariationOfInformation
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/variation-of-information/${compareType}"
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
  clusteringMethod  = it[3]
  ["${clusteringMethod}-${compareClustering}-${baseName}.tsv", it[1].text]
 }
.map { it ->
  splitBaseName = it.getBaseName().split('-')
  compareClustering = "${splitBaseName[1]}-${splitBaseName[2]}"
  clusteringMethod = splitBaseName[0]
  [ 'variation-of-information', compareClustering, clusteringMethod, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ]
 }
.set{ VariationOfInformationProConcat }




process splitJoinTaxa {
  tag { "$d - $spVectors - ${clusteringMethod}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'R/3.3.2'
  time '1h'
  
  input:
  file script from calculateSplitJoin
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(spVectors), val(compareType), val(clusteringMethod) from SplitJoinVectors
  
  output:
  set val(compareType), val(d), file("split-join-*.csv"), val(clusteringMethod) into SplitJoinIndex

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/split-join/${compareType}"
  baseName  = spVectors.getBaseName().split("-")
  taxa      = baseName[1]
  """
  Rscript $script $spVectors $d $taxa
  perl -i -ne 'chomp;my @arrayToSum = split(/\\s+/); shift @arrayToSum; my \$sum; map { \$sum += \$_ } @arrayToSum;print \$_,\" \",\$sum,\"\\n\";' split-join-${taxa}.csv
  """
}

SplitJoinIndex
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/split-join", seed: "distance 1_2 2_1 sum\n") { it ->
  baseName = it[2].getBaseName().split("-")
  taxa = baseName[2]
  [ "${it[3]}-${it[0]}-split-join-${taxa}.csv", it[2].text + "\n"]
 }
.map { it ->
  splitBaseName = it.getBaseName().split('-')
  clusteringMethod = splitBaseName[0]
  
  [ 'split-join', 'vs-rank', clusteringMethod, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set { SplitJoinVsTaxa }


process randIndexRank {
  
  tag { "$clusteringMethod - $d - $randIndexVectors" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  module 'R/3.3.2'
  //  time '1h'
  time   { task.time   * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 4

  
  input:
  file script from CalculateRandIndexTaxa
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(randIndexVectors), val(compareType), val(clusteringMethod) from RandIndexesVectors

  output:
  set val(d), file("rand-index-*.csv"), val(compareType), val(taxa), val(clusteringMethod) into RandIndexVsRank

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/rand-index/${compareType}"
  baseName = randIndexVectors.getBaseName().split("-")
  taxa = baseName[1]
  """
  Rscript $script $randIndexVectors $d $taxa
  """
  
}

RandIndexVsRank
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/rand-index/vs-rank/csv", seed: "distance Rand HA MA FM Jaccard\n") { it ->
  compareClustering = it[2]
  taxa = it[3]
  clusteringMethod = it[4]
  [ "${clusteringMethod}-${compareClustering}-rand-indexes-${taxa}.csv", it[1].text]
 }
.map {  it ->
  splitBaseName = it.getBaseName().split('-')
  clusteringMethod = splitBaseName[0]
  [ 'rand-index', 'vs-rank', clusteringMethod, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set { RandIndexesVsRank }




process splitJoinVsProgenome {
  tag { "${d} - ${Vectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  
  time '1h'
  
  module 'R/3.3.2'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(Vectors), val(compareType), val(clusteringMethod) from VectorProSJ
  file script from CalculateSJProgenome
  
  when:
  seqSrc =~ /^progenome.*/


  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(minSizeCluster), file("$out"), val(clusteringMethod) into SplitJoinIndexPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/split-join/${compareType}"
  inputFile = Vectors.getName()
  out = "split-join-${minSizeCluster}.csv"
  """
  Rscript $script $inputFile $d $out
  perl -i -ne 'chomp;my @arrayToSum = split(/\\s+/); shift @arrayToSum; my \$sum; map { \$sum += \$_ } @arrayToSum;print \$_,\" \",\$sum,\"\\n\";' ${out}
  """

}


SplitJoinIndexPro
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/split-join/vs-progenome", seed: "distance 1_2 2_1 sum\n") { it ->
  
  ["${it[7]}-vs-progenome-split-join-${it[5]}.tsv", it[6].text]
 }
.map {it ->
  splitBaseName = it.getBaseName().split('-')
  clusteringMethod = splitBaseName[0]

  [ 'split-join', 'vs-progenome', clusteringMethod, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
.set{ SplitJoinProConcat }




process randIndexProgenome {

  tag { "${d} - ${randIndexVectors}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true
  time { 6.hour * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 4

  module 'R/3.3.2'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), val(minSizeCluster), file(randIndexVectors), val(compareType), val(clusteringMethod) from VectorProRI
  file script from GetRandIndexPro
  
  when:
  seqSrc =~ /^progenome.*/


  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(minSizeCluster), file("$out"), val(clusteringMethod) into RandIndexPro

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/rand-index/${compareType}"
  inputFile = randIndexVectors.getName()
  out = "rand-index-${minSizeCluster}.csv"
  """
  Rscript $script $inputFile $d $out
  """
}

RandIndexPro
.collectFile(storeDir:"${seqSrc.value}/${seqType.value}/${kmerSize.value}-${sketchSize.value}/rand-index/vs-progenome", seed: "distance Rand HA MA FM Jaccard\n") { it ->
  ["vs-progenome-rand-indexes-${it[7]}-${it[5]}.tsv", it[6].text]
 }
.map { it ->
  splitBaseName = it.getBaseName().split('-')
  clusteringMethod = splitBaseName[4]
  //println clusteringMethod
  [ 'rand-index', 'vs-progenome', clusteringMethod, pvalueThreshold.value, seqSrc.value, seqType.value, kmerSize.value, sketchSize.value, it ] }
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
  
  module 'R/3.3.2'
  
  input:
  set val(indexType), val(comparaisonClustering), val(clusteringMethod), val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(Indexes) from AllIndexesToPlot
  file script from PlotClusteringMetrics
  
  output:
  file "${out}-plot.pdf" into Plots
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${indexType}/${comparaisonClustering}/plot"
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
  
  module 'R/3.3.2'
  
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
distanceMatrix2.first().set { Distancematrix2Value }
//annotatedSilixClusterFile.first().into{ AnnotatedSilixClusterFileValue }



//*******************************************************

process extractGraph {

  tag { "${d} - ${edges} - ${clusteringMethod}" } 
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  //cache 'deep'
  time { task.time * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  maxRetries 2

  time '4h'

  when: 
  false
  
  input:
  set val(d), file(dico), val(clusteringMethod) from annotatedSilixClusterFile
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), file(edges) from Distancematrix2Value
  file script from ExtractCluster
  
  output:
  file("*-nodes.tab") into nodes mode flatten
  file("*-edges.tab") into edges mode flatten
  //set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("*-edges-filter.tab") into EdgesToClique mode flatten
  //val d into DistanceExtractGraph
  
  script:
  // might need to use the ulimit to set the number max of open files
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/graph"
  """
  perl $script $dico $edges ${d} ${seqSrc}-${seqType}-${kmerSize}-${sketchSize}-${d}-${clusteringMethod}
  """

}


// Should create an array...
phase_nodes_g             = Channel.create()
phase_edges_g             = Channel.create()
phase_seq_src_g           = Channel.create()
phase_seq_type_g          = Channel.create()
phase_kmer_size_g         = Channel.create()
phase_sketch_size_g       = Channel.create()
phase_distance_g          = Channel.create()
phase_clustering_method_g = Channel.create()

nodes
.phase(edges) {it ->
  def split_name = it.baseName.split('-')
  return split_name[0] + split_name[1] + split_name[2] + split_name[3] + split_name[4] + split_name[5] + split_name[6].toInteger()
 }
 .separate(phase_nodes_g, phase_edges_g, phase_seq_src_g, phase_seq_type_g, phase_kmer_size_g, phase_sketch_size_g, phase_distance_g, phase_clustering_method_g) { it ->
   //   println it
   def split_name = it[0].baseName.split('-');
   [ it[0], it[1], split_name[0], split_name[1], split_name[2], split_name[3], split_name[4], split_name[5]]
  }


  
phase_nodes_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_nodes_g}

phase_edges_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_edges_g}

phase_seq_src_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_seq_src_g}

phase_seq_type_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_seq_type_g}

phase_kmer_size_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_kmer_size_g}

phase_sketch_size_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_sketch_size_g}

phase_distance_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_distance_g}

phase_clustering_method_g
.buffer( size: params.bsExtractDstanceMatrix, remainder: true )
.set {buf_clustering_method_g}



    // edgeFile = edges[i]
    // if( edgeFile.isFile() ) {
    //   println edgeFile
    //   println edgeFile.getClass()
    //   println edgeFile.size()
    // }
    // println nodeFile.size()
    // sumFileSize += nodeFile.size()



process extractDistanceMatrix {
  //tag { d }
  echo true
  //publishDir "${resultDir}", mode: 'link', overwrite: true
  time '4h'
  cache 'deep'
  memory '60 GB'

  
  input:
  file nodes            from buf_nodes_g
  file edges            from buf_edges_g
  val  seqSrc           from buf_seq_src_g
  val  seqType          from buf_seq_type_g
  val  kmerSize         from buf_kmer_size_g
  val  sketchSize       from buf_sketch_size_g
  val  clusteringMethod from buf_clustering_method_g
  val  d                from buf_distance_g
  file script           from extractDistance
  
  output:
  file "*-distance-matrix.json" into ClusterDistanceMatrix mode flatten
  file "*-taxa.json" into ClusterTaxa mode flatten
  
  script:
  assert nodes.size() == edges.size()
  assert nodes.size() == d.size()
  def cmd = ''
  for( int i=0; i<nodes.size(); i++ ) {
    cmd += "perl $script ${nodes[i]} ${edges[i]} ${d[i]}-${seqSrc[i]}-${seqType[i]}-${kmerSize[i]}-${sketchSize[i]}-${clusteringMethod[i]}\n"
  }
  cmd
}

phase_distance_matrix      = Channel.create()
phase_taxa                 = Channel.create()
phase_distance_dm          = Channel.create() 
phase_seq_src_dm           = Channel.create()
phase_seq_type_dm          = Channel.create()
phase_kmer_size_dm         = Channel.create()
phase_sketch_size_dm       = Channel.create()
phase_clustering_method_dm = Channel.create()


ClusterDistanceMatrix
.phase(ClusterTaxa) {it ->
  //println it
  def split_name = it.baseName.split('-')
  //return split_name[0] + split_name[1].toInteger()
  return split_name[0] + split_name[1] + split_name[2] + split_name[3] + split_name[4] + split_name[5] + split_name[6].toInteger()
 }
 .separate(phase_distance_matrix, phase_taxa, phase_distance_dm, phase_seq_src_dm, phase_seq_type_dm, phase_kmer_size_dm, phase_sketch_size_dm, phase_clustering_method_dm) { it ->
   def split_name = it[0].baseName.split('-');
   //println it
   [ it[0], it[1], split_name[0], split_name[1], split_name[2], split_name[3], split_name[4], split_name[5] ]
  }


phase_distance_matrix
.buffer( size: params.bsTree, remainder: true )
.set {buf_distance_matrix}

phase_taxa
.buffer( size: params.bsTree, remainder: true )
.set {buf_taxa}

phase_distance_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_distance_dm}

phase_seq_src_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_seq_src_dm}

phase_seq_type_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_seq_type_dm}

phase_kmer_size_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_kmer_size_dm}

phase_sketch_size_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_sketch_size_dm}

phase_clustering_method_dm
.buffer( size: params.bsTree, remainder: true )
.set {buf_clustering_method_dm}



process calculateNJTree {

  //publishDir "${resultDir}", mode: 'link', overwrite: true
  time { 3.hour * task.attempt }
  memory { 3.GB * task.attempt }
  errorStrategy { task.exitStatus == 143 ? 'retry' : 'terminate' }
  //cache 'deep'
  // module 'Mash/1.1.1'
  maxRetries 4

  when:
  false
  
  input:
  file script   from nj
  file distance         from buf_distance_matrix
  file taxa             from buf_taxa
  val  seqSrc           from buf_seq_src_dm
  val  seqType          from buf_seq_type_dm
  val  kmerSize         from buf_kmer_size_dm
  val  sketchSize       from buf_sketch_size_dm
  val  clusteringMethod from buf_clustering_method_dm
  val d                 from buf_distance_dm
  

  output:
  file "*-tree.json" into JsonTrees mode flatten
  file "*-tree.nwk" into NewickTrees mode flatten

  script:
  //resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/trees"
  assert d.size() == distance.size()
  assert d.size() == taxa.size()
  def cmd = ''
  def out = ''
  def split_name = ''
  for (int i=0; i<distance.size(); i++) {
    split_name = distance[i].baseName.split('-')
    out = "${seqSrc[i]}-${seqType[i]}-${kmerSize[i]}-${sketchSize[i]}-${clusteringMethod[i]}-${d[i]}-${split_name[6]}-tree"
    cmd += "node --max_old_space_size=3072 $script ${distance[i]} ${taxa[i]} ${out}\n"
  }
  cmd
}

JsonTrees
.subscribe onNext: {it ->
  def f = file(it)
  def split_base_name = f.getBaseName().split('-')

  def seqSrc           = split_base_name[0]
  def seqType          = split_base_name[1]
  def kmerSize         = split_base_name[2]
  def sketchSize       = split_base_name[3]
  def clusteringMethod = split_base_name[4]
  def d                = split_base_name[5]
  
  def resDirStr = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/trees/json"
  def resDir = file(resDirStr)
  resDir.mkdirs()
  f.mklink(resDirStr+'/'+split_base_name[6]+'.json', hard:true, overwrite: true)
 }, onComplete: {println 'Json trees copied'}


NewickTrees
.subscribe onNext: {it ->
  def f = file(it)
  def split_base_name = f.getBaseName().split('-')
  
  def seqSrc           = split_base_name[0]
  def seqType          = split_base_name[1]
  def kmerSize         = split_base_name[2]
  def sketchSize       = split_base_name[3]
  def clusteringMethod = split_base_name[4]
  def d                = split_base_name[5]

  def resDirStr = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results/trees/newick"
  //  def resDirStr = "${params.seqSrc}/${params.seqType}/${params.kmerSize}-${params.sketchSize}/${d}/results/trees/newick"
  def resDir = file(resDirStr)
  resDir.mkdirs()
  def out = resDirStr+'/'+split_base_name[6]+'.nwk'
  f.mklink(out, hard:true, overwrite: true)
 }, onComplete: {println 'Newick trees copied'}



process calculateClusterIntraStat {

  tag { "${d} - ${cluster}" }
  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '1h'

  // when :
  // seqSrc == 'no_db'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(cluster), val(clusteringMethod) from annotatedSilixCluster
  file script from CalculateClusterIntraStat
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("*rank.json"), file("*cluster.json"), val(clusteringMethod) into Stats
  
  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}/results"
  base = cluster.getBaseName()
  out = "${base}-stat"
  """
  perl $script $cluster $out
  """
}


process createJsonData {

  tag { "$d"}
  publishDir "${resultDir}", mode: 'link', overwrite: true

  time '1h'
  
  input:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(rankStats), file(clusterStats), val(clusteringMethod) from Stats

  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("$baseName"), val(clusteringMethod) into Data, DataVisual
  

  script:
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}"
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

  tag { "${pvalueThreshold} - ${seqSrc} - ${seqType} - ${kmerSize} - ${sketchSize} - ${d}" }
  
  time '1h'

  when:
  false
  
  input:
  file script from existsRecord
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(data), val(clusteringMethod) from Data
  
  
  output:
  stdout mash_param_id
  
  script:
  """

  mysql GO_SPE -ABNre \"INSERT INTO MASH_param (distance, pvalue, kmer_size, sketch_size, filtered_orphan_plasmid, seq_type, seq_src, clustering_method) VALUES ($d, $pvalueThreshold, $kmerSize, $sketchSize, TRUE, \'${seqType}\', \'${seqSrc}\', \'${clusteringMethod}\');\"

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
  seq_type = \'${seqType}\'
  AND
  clustering_method = \'${clusteringMethod}\'
  AND
  seq_src = \'${seqSrc}\';\"`

  echo \$val

  """

}


process createClusterTable {


  tag { "${trimmedparamId} : ${kmerSize}-${sketchSize}-${d}" }
  module 'python/3.5.3'
  time '1h'
  
  input:
  val paramId from mash_param_id
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(file) from silixClusterFile2
  file script from GenerateClusterTable
  
  output:
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file("mash_cluster.csv") into  mashClusterFile
  
  script:
  trimmedparamId = paramId.trim()
  //println trimmedparamId
  
  """
  ./$script $file ${trimmedparamId} > mash_cluster.csv
  """

}


process loadClusterFileToDB {
  tag { "$d - ${mashClusterTab}" }
  time '1h'


  when:
  false
  
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
  time '1h'
  
  input:
  file VisualReport
  set val(pvalueThreshold), val(seqSrc), val(seqType), val(kmerSize), val(sketchSize), val(d), file(data_file), val(clusteringMethod) from DataVisual

  output:
  file "visual_report" into VisualReportOut
  
  
  script:
  
  resultDir = "${seqSrc}/${seqType}/${kmerSize}-${sketchSize}/${clusteringMethod}/${d}"
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
