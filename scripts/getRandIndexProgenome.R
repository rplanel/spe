require(clues)


params = commandArgs(trailingOnly=TRUE)
args <- strsplit(params, " ")
file <- args[[1]]
distance <- args[[2]]
print(file)
print(distance)

clusters <- read.csv(file, sep = " ")
res <- adjustedRand(as.vector(clusters[[1]]),as.vector(clusters[[2]]))
resString <- paste(res, collapse=" ")
line <- paste(distance, resString,  sep=" ")
print(line)
write(line, "./rand-index.csv", sep = "\n")
