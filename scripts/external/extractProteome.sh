#!/bin/bash


oidsFile=$1




for line in $(cat $oidsFile)  
do 
    mysql --max_allowed-packet=1G -ABNqr pkgdb_ZR -e \
      "SELECT strtofastaudf(CONCAT_WS('|',GO_id,O_id),gotoprotudf(S_string, GO_begin, GO_end, GO_frame,CONVERT(IF(GO_mutation='selenocysteine',124,IF(GO_mutation='pyrrolysine',125,R_genetic_code)),UNSIGNED) )) 
       FROM Genomic_Object G 
       INNER JOIN Sequence_String SS USING(S_id) 
       INNER JOIN Sequence S USING(S_id) 
       INNER JOIN Replicon R USING(R_id) 
       INNER JOIN Organism USING(O_id) 
       WHERE O_id = $line 
       AND GO_type IN('CDS','fCDS')  
       AND S.S_status = 'inProduction'
       AND GO_evidence = 'automatic' ;" | \
	perl -ne 'if(/^>/){ chomp;($seqId, $oid) = split(/\|/); open($O, ">>", $oid.".faa"); print $O "$seqId\n";} else {s/\*//g;print $O $_}'

done


	    
