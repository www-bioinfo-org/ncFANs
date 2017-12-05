args<-commandArgs(TRUE)
inFile=args[1]
outFile=args[2]
library(DESeq)
mydata=read.table(inFile,head=T,row.names=1)
sampleNum=dim(mydata)[2]
data <- matrix(as.integer(as.matrix(mydata)), nrow = dim(mydata)[1])
print(dim(data))
rownames(data)=rownames(mydata)
colnames(data)=colnames(mydata)
condition = factor( c( 1:as.integer(sampleNum ) ))
cds=newCountDataSet(data,condition)
cds=estimateSizeFactors(cds)
cdsBlind<-estimateDispersions(cds,method="blind")
#cdsBlind<-estimateVarianceFunctions(cds,method="blind")
vst<-getVarianceStabilizedData(cdsBlind)
#vst<-varianceStabilizingTransformation(cdsBlind)
write.table(vst,sep="\t",quote = F, outFile)
