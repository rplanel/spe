require(clues)
##for (distance in c(0.03, 0.035, 0.037, 0.038, 0.039, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.12, 0.13, 0.14, 0.16, 0.17)) {
for (distance in c(0.11, 0.15)) {

    for ( taxa in c("species","genus","family","order","class","phylum") ) {
        file <- paste(
            '/env/cns/home/rplanel/my_proj/test/mash/report/21-1000-1.0E-10-',
            distance,
            "/results/rand-index-",
            taxa,
            ".csv",
            sep=""
        )
        print(file)
        clusters <- read.csv(file,sep = "\t")
        ## for (taxa in c(2,3,4,5,6,7)) {
    
        res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
        ##print(res)
        resString <- paste(res, collapse=" ")
        ##print(resString)
        line <- paste(taxa, distance, resString,  sep=" ")
        print(line)
        write(line, "./rand-index.csv", sep = "\n", append = TRUE)
    }
}
