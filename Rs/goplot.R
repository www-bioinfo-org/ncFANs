args <- commandArgs(TRUE)
file <- args[1]
output <- args[2]
topNum <- as.integer(args[3])

print(file)
print(output)
print(topNum)

maxDrawNum=20

go<-read.table(file,sep="\t",header=F)
go[, 1] <- paste(go[, 2], go[, 3], sep = "\n")
go[, 2] <- -log10(go[, 4])
go <- go[, c(1, 2, 4)]

len=dim(go)[1]
nrow(go)->maxr
max(go[,2])->maxv
a<-go[,1]
b<-go[,3]
go<-go[,2]
print(go)
names(go)<-a


if(len>topNum){
go=go[1:topNum]
} else {
topNum <- length(go)
}

filename=output
jpeg(filename,width = 1880, height = 1800,
units = "px", pointsize = 24, quality = 100, bg = "white",
res = NA)
if(maxr>maxDrawNum  || maxr==maxDrawNum ) {cexv=1.2/maxr*maxDrawNum}
if(maxr<maxDrawNum ) {cexv=1.2}

par(las=2,mar=c(5,20,4.1,2.1),cex=cexv)		
bp <- barplot(sort(go),col="green",horiz=TRUE,space=0.2,width=0.2,xlab=expression(-log10(p-value)),xlim=c(0,(maxv+10)) )

x <- vector()
by <- (maxv + 10) * 0.08
for (i in 1:topNum) {
  if (go[i] > (maxv + 10) * 0.92) {
     x[i] = go[i] - by
  } else {
     x[i] = go[i] + by
  }
}
text(x[topNum:1], y = bp, sprintf("%.2e", b[topNum:1]))

dev.off()  
