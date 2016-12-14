library(ggplot2)
library(reshape)
library(dplyr)

rand_indexes = read.csv("rand-index.csv", sep=" ",dec=".")

##genus <- subset(rand_indexes, taxon == "genus")
##
## + geom_point(data=speciesJoin.3, aes(x=distance, y = value))
for (rank in c("species", "genus")) {
    taxa <- subset(rand_indexes, taxon == rank)
    ##taxa <- subset(rand_indexes, taxon == taxon)
    for (randMethod in c("Rand","HA", "MA", "FM", "Jaccard") ) {
        taxaMethod <- subset(taxa, select = c("seqType", "distance", randMethod))
        taxaMethodJoin <- melt(taxaMethod, id = c("distance", "seqType"))
        taxaMethodJoin %>% group_by(variable) %>% summarise(min = min(value), max = max(value)) -> taxaMethodJoin.2
        left_join(taxaMethodJoin, taxaMethodJoin.2) %>% mutate(color = value == min | value == max) %>% filter(color == TRUE) -> taxaMethodJoin.3
        ggplot(taxaMethodJoin, aes(x = distance, y = value, colour = seqType)) + geom_line() + ggtitle(paste(rank, randMethod)) + geom_point(data=taxaMethodJoin.3, aes(x=distance, y = value))
        out <- paste(rank, "-rand-", randMethod,".pdf", sep="")
        ggsave(out)
    }
}

## speciesMA <- subset(species, select = c("seqType", "distance", "MA"))
## ##speciesNA <- subset(species, seqType == "na")
## ##speciesAA <- subset(species, seqType == "aa")


## ## species[1] <- NULL
## ## species[2] <- NULL
## ## genus[2] <- NULL

## ## genus[1] <- NULL

## ## speciesAA[1] <- NULL
## ## speciesAA[2] <- NULL
## ## speciesAAJoin <- melt(species, id = c("distance"))
## ## speciesJoin <- melt(species, id = c("seqType", "distance"))
## ##genusJoin <- melt(genus, id = "distance")


## speciesMAJoin <- melt(speciesMA, id = c("distance", "seqType"))

## ggplot(speciesMAJoin, aes(x = distance, y = value, colour = seqType)) + geom_line()
## ggsave("species-rand.pdf")


##speciesMAJoin %>% group_by(variable) %>% summarise(min = min(value), max = max(value)) -> speciesMAJoin.2
## left_join(speciesMAJoin, speciesMAJoin.2) %>% mutate(color = value == min | value == max) %>% filter(color == TRUE) -> speciesMAJoin.3


## speciesJoin %>% group_by(variable) %>% summarise(min = min(value), max = max(value)) -> speciesJoin.2
##  left_join(speciesJoin, speciesJoin.2) %>% mutate(color = value == min | value == max) %>% filter(color == TRUE) -> speciesJoin.3


## speciesAAJoin %>% group_by(variable) %>% summarise(min = min(value), max = max(value)) -> speciesAAJoin.2
##  left_join(speciesAAJoin, speciesAAJoin.2) %>% mutate(color = value == min | value == max) %>% filter(color == TRUE) -> speciesAAJoin.3




## ggplot(speciesJoin, aes(x = distance, y = value, colour = variable)) + geom_line() + geom_point(data=speciesJoin.3, aes(x=distance, y = value))
## ggsave("species-rand.pdf")

## genusJoin %>% group_by(variable) %>% summarise(min = min(value), max = max(value)) -> genusJoin.2
## left_join(genusJoin, genusJoin.2) %>% mutate(color = value == min | value == max) %>% filter(color == TRUE) -> genusJoin.3
## ggplot(genusJoin, aes(x = distance, y = value, colour = variable)) + geom_line() + geom_point(data=genusJoin.3, aes(x=distance, y = value))
## ggsave("genus-rand.pdf")
 
