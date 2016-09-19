
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

|task_id|hash|native_id|name|status|exit|submit|duration|realtime|%cpu|rss|vmem|rchar|wchar|
|-------|----|---------|----|------|----|------|--------|--------|----|---|----|-----|-----|


## Problèmes ##

L'utilisation de la fonction *splitFasta* pour découper un multifasta en chunk pose des problèmes de mémoire. La raison vient probablement de la taille des séquences qui peuvent être grande (un génome entier). -> **java heap space**




