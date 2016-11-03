
# Test du logiciel Mash (rplanel Fri Sep 9 12:00:59 CEST 2016) #

## Extraction genomes ##



* Extraction des génomes au format fasta de la base de données.
* Les contigs, chromosomes, plasmides de même organisme ne sont pas dans la même sequence fasta.
* Les sequences fasta qui appartiennent au même organisme seront concatenées.
* Ne peut pas supprimer 1 sketches d'un fichier contenant tous les sketches. Pour éviter les doublons, quand on met à jours un génome qui est déjà dans la base, il faut recréer la base de données de sketches à partir de tous les sketches individuels.



## Exécution workflow ##

```bash
cd /env/cns/proj/agc/home/rplanel/test/mash
nextflow run mash-nextflow.nf -resume \
                              -w data/work \
						      --chunkSize 100 \
						      --genomes data/genome/mic100.fasta
```


## Benchmarks ##


### Single thread sur etna0 ###



## Resultats ##

### Raw data description ###

|Rank   |Number of ranks| Orphan|
|-------|:-------------:|:-----:|
|Strain |5407           |5407   |
|Species|1297           |944    |
|Genus  |359            |143    |
|Family |312/311        |108    |
|Order  |164/163        |44     |
|Class  |71/70          |16     |
|Phylum |29/28          |5      |


### P-Value threshold ###

It seems that the p-value has no effect when distance threshold less than 0.2

### Sketches and kmers effect ###

Need to more analysis

### Best parameters per rank ###

We need to have almost the same clustering as the ncbi one but not exactly the same. 
To check that we can look at:
* The number of cluster per ranks. More the mean is close to 1 (For all the ranks (Species, Genus) how many cluster do I have).
* For a cluster, how many different ranks value do we have (Mean closest to 1).

#### Species ####

|Rank   |Number of ranks| Orphan|
|-------|:-------------:|:-----:|
|Species|2052           |1556   |


|Distance|Number of cluster|Orphan|Nb Species per Cluster (mean)| Nb Cluster per Species(mean)|
|--------|-----------------|------|-----------------------------|-----------------------------|
|0.03    |2417             |1873  |1.1299                       |1.3304                       |
|0.06    |2125             |1587  |1.1802                       |1.2217                       |
|0.065   |2076             |1536  |1.1965                       |1.2100                       |
|0.07    |2033             |1491  |1.2090                       |1.1973                       |
|0.1     |1791             |1275  |1.3093                       |1.1423                       |


## Problèmes ##

* L'utilisation de la fonction *splitFasta* pour découper un multifasta en chunk pose des problèmes de mémoire. La raison vient probablement de la taille des séquences qui peuvent être grande (un génome entier). -> **java heap space**
* mash dist ne support pas une p-value inférieur à 1e-30 pour le filtre. 


```bash
loadFileToMySQLDB.sh cluster.DB GO_SPE MASH_cluster '\t' '\n' no yes

```



