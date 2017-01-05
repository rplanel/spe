require(clues)

params = commandArgs(trailingOnly=TRUE)
args <- strsplit(params, " ")
dir <- args[[1]]
distance <- args[[2]]

for ( taxa in c("species","genus","family","order","class","phylum") ) {
    file <- paste(
        dir,
        "/vector-rand-index-",
        taxa,
        ".csv",
        sep=""
    )
    print(file)
    clusters <- read.csv(file,sep = "\t")
    res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
    resString <- paste(res, collapse=" ")
    line <- paste(distance, resString,  sep=" ")
    fileOut <- paste("./rand-index-", taxa,".csv", sep="")
    print(line)
    write(line, fileOut, sep = "\n")
}



## Amino acid

## for (distance in c(0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.11, 0.12, 0.13, 0.14)) {
##     for ( taxa in c("species","genus","family","order","class","phylum") ) {
##         file <- paste(
##             ##'/env/cns/home/rplanel/my_proj/test/mash/report/21-1000-1.0E-10-',
##             '/env/cns/home/rplanel/my_proj/test/mash/data/runs/aa/9-1000/1E-10-',
##             distance,
##             "/results/rand-index-",
##             taxa,
##             ".csv",
##             sep=""
##         )
##         print(file)
##         clusters <- read.csv(file,sep = "\t")
##         ## for (taxa in c(2,3,4,5,6,7)) {
    
##         res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
##         ##print(res)
##         resString <- paste(res, collapse=" ")
##         ##print(resString)
##         line <- paste("aa", taxa, distance, resString,  sep=" ")
##         print(line)
##         write(line, "./rand-index.csv", sep = "\n", append = TRUE)
##     }
## }

## clusters <- read.csv("/env/cns/home/rplanel/my_proj/test/mash/data/rand-index/progenome/progenomeCluster-mashCluster.no-string.csv",sep = " ")
## ## for (taxa in c(2,3,4,5,6,7)) {
## res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]), randMethod = c("Jaccard"))
## ## print(res)
## resString <- paste(res, collapse=" ")
## ##print(resString)
## line <- paste(resString,  sep=" ")
## print(line)

