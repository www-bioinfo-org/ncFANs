#!/usr/bin/python
import sys
from operator import itemgetter, attrgetter
from optparse import OptionParser
import re
import time

def read_gtf(path,flag):
    result=[]
    f = open(path,'r')
    gene={}
    line=f.readline()
    while line:
        item=line.split("\t")
        chrom=item[0]
        start=int(item[3])
        end=int(item[4])
        gid=re.findall(r'gene_id.+?"(.+?)"',item[8])[0]
        if gid in gene:
            gene[gid].append([chrom,start,end,gid])
        else:
            gene[gid]=[[chrom,start,end,gid]]
        line=f.readline()
    f.close()
    for gid in gene:
        exons=gene[gid]
        exons=sorted(exons, key=itemgetter(0,1))
        first=exons[0]
        last=exons[-1]
        result.append([first[0],first[1],last[2],first[3],flag])
    return result

def cal_dis(A,B):
    chrA=A[0]
    startA=A[1]
    endA=A[2]
    chrB=B[0]
    startB=B[1]
    endB=B[2]
    if chrA != chrB:
        return sys.maxint
    if endA >= startB:
        return 0
    else:
        return startB-endA

def add(neighbors,x,y,dis):
    flagx=x[4]
    namex=x[3]
    flagy=y[4]
    namey=y[3]
    if flagx == 'noncoding':
        name=namex
        neighbor=namey
    else:
        name=namey
        neighbor=namex
    if name in neighbors:
        neighbors[name].append([neighbor,dis])
    else:
        neighbors[name]=[[neighbor,dis]]



usage="""

    find_neighbor.py: obtain the neighboring coding-lincRNA gene pairs
    Usage: find_neighbor.py [-h] -c coding_gtf -n lincRNA_gtf -o out_file

"""
parser = OptionParser(usage=usage)
parser.add_option("-c", "--coding_gtf", dest="coding_gtf", help="(Required.) "
                  +"The path of coding gene gtf file. Two mandatory attributes"
                      +" (gene_id \"value\"; transcript_id \"value\") should be provided in the file. "
                      +"Some files which has already been prepared could be download at"
                      +" http://wwww.bioinfo.org/software/cnci .")
parser.add_option("-n", "--lincRNA_gtf", dest="lincRNA_gtf", help="(Required.) "
                  +"The path of lincRNA gene gtf file. Two mandatory attributes"
                      +" (gene_id \"value\"; transcript_id \"value\") should be provided in the file. "
                      +"Some files which has already been prepared could be download at"
                      +" http://wwww.bioinfo.org/software/cnci .")
parser.add_option("-o", "--out_file", dest="out_file", help="(Required.) The path of output file")
(options, args) = parser.parse_args()

if options.coding_gtf is not None:
    coding_gtf=options.coding_gtf
else:
    print parser.print_help()
    exit("Error: Coding gene gtf file is required!")
if options.lincRNA_gtf is not None:
    lincRNA_gtf=options.lincRNA_gtf
else:
    print parser.print_help()
    exit("Error: LincRNA gene gtf file is required!")
if options.out_file is not None:
    out_file=options.out_file
else:
    print parser.print_help()
    exit("Error: output file is required!")

start_time=time.time()
print "Neighbor gene searching start:"
coding=read_gtf(coding_gtf,'coding')
noncoding=read_gtf(lincRNA_gtf,'noncoding')

total_genes=[]
total_genes.extend(coding)
total_genes.extend(noncoding)
neighbors={}
total_genes=sorted(total_genes, key=itemgetter(0,1))
genes_number=len(total_genes)
for index in range(genes_number):
    x=total_genes[index]
    for forward_index in range(index+1,genes_number):
        y=total_genes[forward_index]
        if x[4]== y[4]:
            continue
        dis=cal_dis(x,y)
        if dis == sys.maxint:
            break
        elif dis >= 0:
            add(neighbors,x,y,dis)
            break

f = open(out_file,"w")
for name in neighbors:
    array_neighbors=neighbors[name]
    array_neighbors=sorted(array_neighbors, key=itemgetter(1))
    for neighbor in array_neighbors:
        out_line=name+"\t"+neighbor[0]+"\t"+str(neighbor[1])
        f.write(out_line + "\n")
        if neighbor[1] > 0 :
            break
f.close()

run_time=int((time.time() - start_time))
exit("Neighbor gene searching complete: "+"%f seconds elapsed " % run_time )