library(WGCNA)
library(multtest)
args <- commandArgs(TRUE)

cfile <- args[1]
ncfile <- args[2]
cor.file <- args[3]
top <- as.numeric(args[4])
adjusted <- as.numeric(args[5])

coding <- as.matrix(read.table(cfile, header = T, row.names = 1, sep = "\t"))
#print("coding expression")
#dim(coding)
noncoding <- as.matrix(read.table(ncfile, header = F, row.names = 1, sep = "\t"))
#print("noncoding expression")
#dim(noncoding)
expdata <- rbind(coding, noncoding)
colnames(expdata) <- colnames(coding)
expdata.d<-abs(cor(t(expdata),method = "pearson"))
len<-ncol(expdata)

min <- 1
pb <- txtProgressBar(min = 0, max = ncol(expdata.d), style = 3)
for (i in 1:ncol(expdata.d)) {
  setTxtProgressBar(pb, i)
  acor<-quantile(expdata.d[i,], 1 - top)
  corinfo <- paste("corinfo",acor,sep="\t")
	
  write.table(corinfo,file=cor.file,sep="\t",row.names=F,col.names=F,append=T)
	
  set.p <- corPvalueFisher(expdata.d[i,],len)
  
  set.q<- mt.rawp2adjp(set.p,proc = "Bonferroni")
  q<-set.q[[1]][,2]
  col<-set.q[[2]][q < adjusted]
  mycor<-t(as.matrix(expdata.d[i, col]))
  rownames(mycor)<-rownames(expdata.d)[i]
  link<-paste(rownames(mycor),colnames(mycor),sep="\t")
  link<-paste(link,mycor[1,],sep="\t")
  write.table(link,file=cor.file,sep="\t",row.names=F,col.names=F,append=T)
}
close(pb)
