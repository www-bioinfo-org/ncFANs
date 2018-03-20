import sys
inputFile=sys.argv[1]
outputFile=sys.argv[2]
refNoncoding=sys.argv[3]
refCoding=sys.argv[4]

def RemoveDup(stri):
    num=stri.find("(")
    if num > 0:
        return stri[0:num]
    else:
        return stri

SampleGene={}
refNoncodingSet=[]
refCodingSet=[]

print "extract list and annovar c or kn or nn..."

f=open(inputFile)
fline=f.readline()
if fline:
    fline=f.readline()
f_exp = open(outputFile+"-exp.txt",'w')
while fline:
    line=fline.strip("\n").split("\t")
    gene=line[0]
    #print fline
    if gene not in SampleGene:
       SampleGene[gene]="0"
       f_exp.write(fline)
    else:
       print "Warning: Dup name! Filtered!"

    #SampleGene.append(fline[0])
    #print fline[0]
    fline=f.readline()
f.close()
f_exp.close()
f=open(refNoncoding)
fline=f.readline()
while fline:
    fline=fline.strip("\r\n")
    refNoncodingSet.append(fline)
    fline=f.readline()
f.close()

f=open(refCoding)
fline=f.readline()
while fline:
    fline=fline.strip("\r\n")
    refCodingSet.append(fline)
    fline=f.readline()
f.close()

testList=[]

for key in SampleGene:
    keyTemp=""
    keyTemp = RemoveDup(key)
    testList.append(keyTemp)
    if keyTemp in refCodingSet:
        SampleGene[key]="c"
    else:
        if keyTemp in refNoncodingSet:
            SampleGene[key]="kn"
        else:
            SampleGene[key]="nn"

print "geneList:",len(testList)
testList=set(testList)
print "geneList set :",len(testList)

f=open(outputFile,"w+")
for key in SampleGene:
    writeLine=key
    writeLine+="\t"
    writeLine+=SampleGene[key]
    writeLine+="\n"
    f.write(writeLine)
f.close()

numC=0
numKN=0
numNN=0
numA=0

for key in SampleGene:
    numA=numA+1
    if SampleGene[key] == "c":
        numC=numC+1
    if SampleGene[key] == "kn":
        numKN=numKN+1
    if SampleGene[key] == "nn":
        numNN=numNN+1

print "input:",len(SampleGene)
#print SampleGene
print "ref known noncoding:",len(refNoncodingSet)
#print refNoncodingSet
print "ref coding:",len(refCodingSet)
#print refCodingSet

print "sampleGene:",len(SampleGene)
print "C=",numC
print "KN=",numKN
print "NN=",numNN
print "numA",numA

