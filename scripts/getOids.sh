#!/bin/bash


mysql  --max_allowed-packet=1G -ABNqr pkgdb_ZR -e \
"
SELECT DISTINCT O_id FROM Organism 
INNER JOIN Replicon USING(O_id) 
INNER JOIN Sequence USING(R_id) 
INNER JOIN Sequence_String USING(S_id) 
LEFT JOIN Contig USING(S_id) 
WHERE S_status = 'inProduction' 
AND S_id NOT IN (3142) 
AND O_id 
IN 
(SELECT DISTINCT O_id         
FROM Organism          
INNER JOIN Replicon USING(O_id)         
INNER JOIN Sequence USING(R_id)         
WHERE R_type IN ('chromosome','WGS')         
AND S_status = 'inProduction' GROUP BY O_id);
"
