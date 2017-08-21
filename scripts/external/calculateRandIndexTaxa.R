require(clues)
params = commandArgs(trailingOnly=TRUE)
args <- strsplit(params, " ")
fileRandIndex <- args[[1]]
distance <- args[[2]]
taxa <- args[[3]]

clusters <- read.csv(fileRandIndex,sep = "\t")
res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
resString <- paste(res, collapse=" ")
line <- paste(distance, resString,  sep=" ")
fileOut <- paste("./rand-index-", taxa,".csv", sep="")
print(line)
write(line, fileOut, sep = "\n")


