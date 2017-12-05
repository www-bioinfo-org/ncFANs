#!/usr/bin/python
#-*-coding : utf-8-*-
#Copyright(c) 2014 - SunLiang <sunliang@bioinfo.ac.cn>
import optparse
import sys
import math
import re
import time
import subprocess
parse=optparse.OptionParser()
parse.add_option('-i','--novelnc',dest='novelnc',action='store',metavar='input gtf file',help='enter your gtf file')
parse.add_option('-n','--noncoding',dest='noncoding',action='store',metavar='input gtf file',help='enter your gtf file')
parse.add_option('-c','--coding',dest='coding',action='store',metavar='input gtf file',help='enter your gtf file')
parse.add_option('-o','--output',dest='output',action='store',metavar='assign you output file',help='enter your output file')
(options,args) = parse.parse_args()
#############################################################################
O_inPutFileName = options.novelnc
N_inPutFileName = options.noncoding
C_inPutFileName = options.coding
#O_outPutFileName = options.output
#subprocess.call('mkdir '+O_outPutFileName+'' , shell=True)
O_Arr = O_inPutFileName.split(',')
N_Arr = N_inPutFileName.split(',')
C_Arr = C_inPutFileName.split(',')
GENE_LIST = options.output
LIST = open(GENE_LIST,'w')
#############################################################
def Extract(file,pro):
    inFiles = open(file)
    inFilesArr = inFiles.read()
    inputArray = inFilesArr.split('\n')
    temp_file_len = len(inputArray) - 1
    del inputArray[temp_file_len]
    inFiles.close()
    Tot_array = []
    for i in range(len(inputArray)):
        tmp = inputArray[i]
        tmp_str = re.sub('\t',' ',tmp)
        tmp_array = tmp_str.split(' ')
        for j in range(len(tmp_array)):
            temp = tmp_array[j]
            if 'gene_id' in temp:
	        Temp_xloc =  tmp_array[j+1]
                Tot_array.append(Temp_xloc)
    TOT_Arr = []
    for i in range(len(Tot_array)):
        tmp_str = ''
        tmp_string = ''
        tmp = Tot_array[i]
        tmp_str = re.sub('"','',tmp)
        tmp_string = re.sub(';','',tmp_str)
        TOT_Arr.append(tmp_string)
    Final_list =  list(set(TOT_Arr))
    for i in range(len(Final_list)):
        tmp = Final_list[i]
        temp = tmp + '\t' + pro + '\n'
        LIST.write(temp)     
###################################################################
Compute_time = time.time()
for i in range(len(O_Arr)):
    temp = O_Arr[i]
    Extract(temp,'NovelNoncoding')
for i in range(len(N_Arr)):
    temp = N_Arr[i]
    Extract(temp,'Noncoding')
for i in range(len(C_Arr)):
    temp = C_Arr[i]
    Extract(temp,'Coding')
LIST.close()
print "%f second for" % (time.time() - Compute_time) + ' ' + "Done!"
