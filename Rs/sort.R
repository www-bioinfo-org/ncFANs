args <- commandArgs(TRUE)
list <- args[1]
expression <- args[2]
dir <- args[3]

gene.list <- read.table(list, header = F, sep = "\t", 
                        colClasses = rep("character", 2))
coding.list <- gene.list[gene.list[, 2] == "c", 1]
noncoding.list <- gene.list[grep("n", gene.list[, 2]), 1]
expdata <- read.table(expression, row.names = 1, header = T, sep = "\t")
coding.exp <- expdata[coding.list, ]
noncoding.exp <- expdata[noncoding.list, ]
noncoding.var <- sort(apply(noncoding.exp, 1, var), decreasing = T)

path <- file.path(dir, "expdata.tmp") 
write.table(coding.exp, file = path, col.names = T, row.names = T, 
            sep = "\t", quote = F)
write.table(expdata[names(noncoding.var), ], file = path,  col.names = F,
            row.names = T, sep = "\t", quote = F, append = T)
