import os, sys, shutil
from subprocess import call as subcall


class CallException(Exception):
    def __init__(self, cmd):
        self.value = "Call Error! CMD: " + cmd


def call(cmd, shell=True):
    try:
        flag = subcall(cmd, shell=shell)
        if flag != 0:
            raise CallException(cmd)
        return True
    except CallException, e:
        print e.value
        sys.exit(flag)


def moveFile(inFile, outFile):
    shutil.move(inFile, outFile)
    return True


class ncFANs:
    def __init__(self, ncFANsDir):
        self.path = ncFANsDir

    def filterGeneList(self, expFile, geneList, outDir):
        path = self.path
        path += "/filter_gene_list.pl"
        filter_cmd = "perl %s -g %s -e %s -o %s -s 3 -t 0" % (path, geneList, expFile, outDir)
        print filter_cmd
        filter_r = call(filter_cmd, shell=True)
        return True

    def extractAndAnno(self, expFile, outGenelist, knoncoding, coding):
        path = self.path
        path += "/extractanno.py"
        extract_cmd = "python %s %s %s %s %s" % (path, expFile, outGenelist, knoncoding, coding)
        print extract_cmd
        extract_r = call(extract_cmd, shell=True)
        return True

    def conetwork(self, genelist, expFile, outDir):
        path = self.path
        path += "/cnc.pl"
        cnc_cmd = "perl %s -g %s -e %s -o %s -r 0" % (path, genelist, expFile, outDir)
        print cnc_cmd
        cnc_r = call(cnc_cmd, shell=True)
        return True

    def predictFunction(self, network, customGo, term_GO, outDir):
        path = self.path
        path += "/function_predict.pl"
        pred_cmd = "perl %s -n %s -g2go %s -bp -cc -mf -m 30 -mc 10 -hc 10 -o %s -termGO %s -g" % (
            path, network, customGo, outDir, term_GO)
        pred_r = call(pred_cmd, shell=True)
        return True

    def getGeneList(self, edgeDir):
        path = self.path
        path += "/getGeneList.pl"
        f_list = os.listdir(edgeDir)
        for file in f_list:
            file = "%s/%s" % (edgeDir, file)
            if file[-5:] == '_edge':
                conv_cmd = "perl %s -e %s -o %s" % (path, file, edgeDir)
                conv_r = call(conv_cmd, shell=True)
                bakFile = file + ".bak"
                with open(file, 'r') as fin:
                    with open(bakFile, 'w') as fout:
                        for line in fin:
                            fout.write(
                                "\t".join([x.rstrip("_kn").rstrip("_nn") for x in line.rstrip().split("\t")]) + "\n")
                fin.close()
                fout.close()
                moveFile(bakFile, file)


def funcPredict_ncFANs(ncFANsDir, expFile, knoncoding, coding, customGo, termGO, outDir):
    lnc = ncFANs(ncFANsDir)

    expFileGenelist = os.path.join(outDir, "%s-genelist" % (os.path.split(expFile)[1]))
    lnc.extractAndAnno(expFile, expFileGenelist, knoncoding, coding)

    lnc.filterGeneList(expFile, expFileGenelist, outDir)

    genelistOut = "%s/filtered.gene.list-1" % (outDir)
    filterExpFile = "%s/filtered.expression.txt" % (outDir)
    lnc.extractAndAnno(filterExpFile, genelistOut, knoncoding, coding)

    lnc.conetwork(genelistOut, filterExpFile, outDir)

    networkFile = "%s/network_1" % (outDir)
    functionDir = "%s/function" % (outDir)
    lnc.predictFunction(networkFile, customGo, termGO, functionDir)
    hub_edge = os.path.join(functionDir, 'Hub_edge')
    module_edge = os.path.join(functionDir, 'Module_edge')
    lnc.getGeneList(hub_edge)
    lnc.getGeneList(module_edge)

    outDict = {'expFileGeneList': expFileGenelist, 'filterdFpkm': filterExpFile, 'filterGeneList': genelistOut,
               'cncNetwork': networkFile, 'funcResult': functionDir, 'Hub_edge': hub_edge,
               'Module_edge': module_edge}
    return outDict


if __name__ == '__main__':
    filepath = sys.argv[0]
    if "/" in filepath:
        ncFANsDir = os.path.dirname(filepath)
    else:
        ncFANsDir = "."
    expFile = sys.argv[1]
    knoncoding = sys.argv[2]
    coding = sys.argv[3]
    customGo = sys.argv[4]
    termGO = sys.argv[5]
    outDir = sys.argv[6]
    # print(ncFANsDir, expFile, knoncoding, coding, customGo, termGO, outDir)
    funcPredict_ncFANs(ncFANsDir, expFile, knoncoding, coding, customGo, termGO, outDir)