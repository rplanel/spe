library(ggplot2)
library(ggrepel)


## files <- c("clustering-metrix-res-cluster.tsv","clustering-metrix-res-species.tsv","clustering-metrix-res-genus.tsv")
## files <- c("clustering-metrix-res-species.tsv","clustering-metrix-res-genus.tsv","clustering-metrix-res-family.tsv","clustering-metrix-res-order.tsv")

## progenome
files <- c(
    "./metric-results/clustering-similarity-result-rand-index-family.tsv",
    "./metric-results/clustering-similarity-result-rand-index-order.tsv",
    "./metric-results/clustering-similarity-result-variation-of-information-family.tsv",
    "./metric-results/clustering-similarity-result-variation-of-information-order.tsv",
    "./metric-results/clustering-similarity-result-rand-index-genus.tsv",
    "./metric-results/clustering-similarity-result-rand-index-species.tsv",
    "./metric-results/clustering-similarity-result-variation-of-information-genus.tsv",
    "./metric-results/clustering-similarity-result-variation-of-information-species.tsv",
    "./metric-results/clustering-similarity-result-variation-of-information-cluster.tsv",
    "./metric-results/clustering-similarity-result-rand-index-cluster.tsv"
)


## microscope
## files <- c(
##     ## "./metric-results/clustering-similarity-result-rand-index-family.tsv",
##     ## "./metric-results/clustering-similarity-result-rand-index-order.tsv",
##     ## "./metric-results/clustering-similarity-result-variation-of-information-family.tsv",
##     ## "./metric-results/clustering-similarity-result-variation-of-information-order.tsv",
##     "./metric-results/clustering-similarity-result-rand-index-genus.tsv",
##     "./metric-results/clustering-similarity-result-rand-index-species.tsv",
##     "./metric-results/clustering-similarity-result-variation-of-information-genus.tsv",
##     "./metric-results/clustering-similarity-result-variation-of-information-species.tsv",
##     "./metric-results/clustering-similarity-result-split-join-genus.tsv",
##     "./metric-results/clustering-similarity-result-split-join-species.tsv"

    
## )



for(f in files){
    
    clustering <- read.csv(f, sep = "\t", header = TRUE)

    ## Geom all
    outFile <- paste(f,'pdf', sep = ".")
    min_point <- clustering[which.min(clustering$metric),]
    max_point <- clustering[which.max(clustering$metric),]

    lineD <- ggplot(
        clustering,
        aes_string(x="distance", y = "metric", linetype="clustering.method", colour="sketch.size")
    ) + geom_line(size = 0.2) + geom_point(size=0.5) + geom_point(data = min_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = min_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + geom_point(data = max_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = max_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + ggtitle(f)
    ggsave(outFile, plot = lineD)





    ## Violin all
    outFileViolin <- paste(f,'violin','pdf', sep = ".")
    clustering_filtered <- subset(clustering, distance <= 0.07 & distance > 0.02)
    violinDraw <- ggplot(clustering_filtered, aes(x = distance, y = metric)) + geom_violin(trim=FALSE, aes(group = distance), draw_quantiles = c(0.25, 0.5, 0.75)) + geom_point(aes_string(colour="sketch.size", shape="clustering.method", stroke=FALSE))
    ggsave(outFileViolin, plot = violinDraw)






    ## 21* louvain
    outFile21 <- paste(f,'21','pdf', sep = ".")
    clustering_21_louvain <- subset(clustering, ( clustering.method == "louvain" | clustering.method == "silix" ) & (sketch.size == "21-1000" | sketch.size == "21-5000" | sketch.size == "21-10000" | sketch.size == "21-50000"))
    min_point <- clustering_21_louvain[which.min(clustering$metric),]
    max_point <- clustering_21_louvain[which.max(clustering$metric),]
    louvain_21 <- ggplot(
        clustering_21_louvain,
        aes_string(x="distance", y = "metric", linetype="clustering.method", colour="sketch.size")
    ) + geom_line(size = 0.2) + geom_point(size=0.5) + geom_point(data = min_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = min_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + geom_point(data = max_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = max_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + ggtitle(f)
    ggsave(outFile21, plot = louvain_21)


    ## 21* louvain violin
    outFileViolin <- paste(f,'violin', '21', 'pdf', sep = ".")
    clustering_21_louvain_subset <- subset(clustering_21_louvain, distance <= 0.1 & distance >= 0.03)
    violinDraw <- ggplot(clustering_21_louvain_subset, aes(x = distance, y = metric)) + geom_violin(trim=FALSE, aes(group = distance), draw_quantiles = c(0.25, 0.5, 0.75)) + geom_point(aes_string(colour="sketch.size", shape="clustering.method", stroke=FALSE))
    ggsave(outFileViolin, plot = violinDraw)


    ## 18* louvain
    outFile18 <- paste(f,'18','pdf', sep = ".")
    clustering_18_louvain <- subset(clustering, ( clustering.method == "louvain" | clustering.method == "silix" ) & (sketch.size == "18-1000" | sketch.size == "18-5000" | sketch.size == "18-10000" | sketch.size == "18-50000"))
    min_point <- clustering_18_louvain[which.min(clustering$metric),]
    max_point <- clustering_18_louvain[which.max(clustering$metric),]
    louvain_18 <- ggplot(
        clustering_18_louvain,
        aes_string(x="distance", y = "metric", linetype="clustering.method", colour="sketch.size")
    ) + geom_line(size = 0.2) + geom_point(size=0.5) + geom_point(data = min_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = min_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + geom_point(data = max_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = max_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + ggtitle(f)
    ggsave(outFile18, plot = louvain_18)


    ## 18* louvain violin
    outFileViolin <- paste(f,'violin', '18', 'pdf', sep = ".")
    clustering_18_louvain_subset <- subset(clustering_18_louvain, distance <= 0.1 & distance >= 0.03)
    violinDraw <- ggplot(clustering_18_louvain_subset, aes(x = distance, y = metric)) + geom_violin(trim=FALSE, aes(group = distance), draw_quantiles = c(0.25, 0.5, 0.75)) + geom_point(aes_string(colour="sketch.size", shape="clustering.method", stroke=FALSE))
    ggsave(outFileViolin, plot = violinDraw)


    

    ## 18* louvain
    ## outFile18 <- paste(f,'18','pdf', sep = ".")
    ## clustering_18_louvain <- subset(clustering, clustering.method == "louvain" & (sketch.size == "18-1000" | sketch.size == "18-5000" | sketch.size == "18-10000" | sketch.size == "18-50000"))
    ## min_point <- clustering_18_louvain[which.min(clustering$metric),]
    ## max_point <- clustering_18_louvain[which.max(clustering$metric),]
    ## louvain_18 <- ggplot(
    ##     clustering_18_louvain,
    ##     aes_string(x="distance", y = "metric", linetype="clustering.method", colour="sketch.size")
    ## ) + geom_line(size = 0.2) + geom_point(size=0.5) + geom_point(data = min_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = min_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + geom_point(data = max_point, aes_string(x="distance",y="metric"), color = "black", size = 0.5) + geom_text(vjust=2, data = max_point, size = 1.2, aes(label = paste(sketch.size, " (",distance, " ; ",round(metric, digits = 4), ")", sep="")))  + theme(text = element_text(size=4)) + ggtitle(f)
    ## ggsave(outFile18, plot = louvain_18)

}

