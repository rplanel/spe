require(igraph)
params = commandArgs(trailingOnly=TRUE)
args     <- strsplit(params, " ")
file     <- args[[1]]
distance <- args[[2]]
taxa     <- args[[3]]

clusters <- read.csv(file, sep = "\t")
res <- split_join_distance(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
resString <- paste(res, collapse=" ")
line <- paste(distance, resString,  sep=" ")

fileOut <- paste("./split-join-", taxa,".csv", sep="")
print(line)
write(line, fileOut, sep = "\n")
