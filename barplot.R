file <- commandArgs(TRUE)
network <- read.table(file[1], sep = "\t")
network <- as.matrix(network[, 1:2])
jpeg(file[2])
barplot(table(table(network)), xlab = "degree", ylab = "frequency")
dev.off()

