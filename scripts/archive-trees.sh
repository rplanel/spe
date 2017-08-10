#!/bin/bash

## Se mettre dans le dossier na (faire un lien symbolique du script)
find ./ -maxdepth 5 -type d -name trees | cut -d '/' -f1,2,3,4,5 > list-tree-dir.txt
jobify -- 'for f in `cat list-tree-dir.txt`; do echo $f; tar --remove-files -cf "${f}/trees.tar" "${f}/trees/" ; done'
