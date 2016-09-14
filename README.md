
# Test du logiciel Mash (rplanel Fri Sep 9 12:00:59 CEST 2016) #

## Extraction genomes ##


Extraction des génomes au format fasta de la base de données.
Les contigs, chromosomes, plasmides de même organisme ne sont pas dans la même sequence fasta.
Ils seront concatenés durant l'exécution du workflow.

```
mysqlagc --max_allowed-packet=1G -ABNqr pkgdb_dev -e "SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string)
FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) 
INNER JOIN Sequence_String USING(S_id) 
WHERE rank = 'order' AND S_status = 'inProduction'" >  data/genome/mic_all.fasta
```


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



4218325
