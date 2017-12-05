import sys
import re
arg1=sys.argv[1]

with open(arg1,'r')as file2:
    with open(arg1+"+",'w')as file3:
        for e in file2:
            line=re.split("\t|_",e)
            file3.writelines(line[0]+"_"+line[2]+"\t"+line[3]+"_"+line[5]+"\t"+line[6].strip()+'\n')
