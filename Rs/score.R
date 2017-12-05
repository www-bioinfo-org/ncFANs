file <- commandArgs(TRUE)
network <- read.table(file, sep = "\t", 
                      colClasses = c("character", "character", "numeric"))
indegrees <- table(as.matrix(network[, 1:2]))
freq <- table(indegrees)
degree <- as.integer(names(freq))
avg <- sum(indegrees) / length(indegrees)
if (is.na(avg)) {
   avg <- 0
}
p.k <- log(freq)
k <- log(degree)
scale.score <- cor(p.k, k) ^ 2
if (is.na(scale.score)) {
   scale.score <- 0
}
solve.matrix <- cbind(rep(1, length(scale.score)), k)

svd <- svd(solve.matrix)
solve.matrix <- svd$v %*% diag(1/svd$d) %*% t(svd$u) %*% p.k
if (is.na(solve.matrix[2])) {
   solve.matrix[2] <- 0
}
write.table(cbind(avg, scale.score, -solve.matrix[2]), 
            file = paste(file, ".score", sep = ""), row.names = F, 
            col.names = F, sep = "\t", quote = F)
