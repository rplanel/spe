#!/bin/bash

oidsFile=$1


for line in $(cat $oidsFile)  
do 
    mysql  --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
	   "SELECT strtofastaudf(O_id,IF(C_id IS NULL,S_string,gotonucudf(S_string, C_begin, C_end, '+1'))) 
            FROM       Organism 
            INNER JOIN Replicon USING(O_id) 
            INNER JOIN Sequence USING(R_id) 
            INNER JOIN Sequence_String USING(S_id) 
            LEFT  JOIN Contig USING(S_id) 
            WHERE O_id = $line
            AND S_status = 'inProduction';"  | \

    awk '$0=="NULL"{print "Error: bad sequence extraction " > "/dev/stderr"; exit 1} /^>/{ Oid=$1; sub(">","",Oid); fileout=Oid".fna.gz";} {print $0 | "gzip -c > "fileout }'

done



# mysql  --max_allowed-packet=1G -ABNqr pkgdb_dev -e "SELECT O_id, IF(C_id IS NULL,'no contig',gotonucudf(S_string,C_begin, C_end, '+1')) FROM Organism  INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) INNER JOIN Sequence_String USING(S_id) LEFT JOIN Contig USING(S_id) WHERE S_status = 'inProduction';" > log




# mysql  -u$MYAGCUSER -p$MYAGCPASS -h$MYAGCHOST --max_allowed-packet=1G -ABNqr $MYAGCDB -e "
# SELECT strtofastaudf(O_id,IF(C_id IS NULL,S_string,gotonucudf(S_string, C_begin, C_end, '+1'))) 
# FROM Organism 
# INNER JOIN Replicon USING(O_id)
# INNER JOIN Sequence USING(R_id) 
# INNER JOIN Sequence_String USING(S_id)
# LEFT JOIN Contig USING(S_id) 
# WHERE S_status = 'inProduction' AND O_id IN (31,56,2751);" | awk '/^>/{ Oid=$1; sub(">","",Oid); fileout=Oid".fna"} {print $0 > fileout}'




# mysql --max_allowed-packet=1G -ABNqr pkgdb_dev -e \
#     \"SELECT strtofastaudf(CONCAT_WS(' ',O_id, O_name, name_txt),S_string) \
#     FROM Organism LEFT JOIN O_Taxonomy USING(O_id) INNER JOIN Replicon USING(O_id) INNER JOIN Sequence USING(R_id) \
#     INNER JOIN Sequence_String USING(S_id) \
#     WHERE rank = 'order' AND S_status = 'inProduction' AND O_id=${oid}\" >  ${filenameOut}
