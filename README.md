# ncFANs
## About ncFANS

ncFANs has introduced a highly efficient way of re-using the abundant pre-existing microarray data. It is expected that the strategies developed in these studies will provide new clues and approaches for the study of lncRNA functions, and the predicted functions will give directions for molecular biological experiments.

## Install ncFANs

## USAGE
ncFANs needs 6 parameters to run correctly, and the information of these parameters is as follows. A demo command is also provided.

### Parameters
* expFile
    Expression profile file
* knoncodingFile 
    A file with only one column of noncoding gene names
* coding
    A file with only one column of coding gene names
* customGo
    A file of the map of gene names and GO IDs
* termGO
    A file containing GO information
* outDir
  directory to store your results
 
### Example

    cd /your/install/path
    python ncFANs.py example/mouse_uniq.fpkm example/noncoding.list example/coding.list /example/human_custom_go /example/GOTerm.txt /your/outdir/

## Citation
[Guo X, Gao L, Liao Q, et al. Long non-coding RNAs function annotation: a global prediction method based on bi-colored networks[J]. Nucleic Acids Research, 2013, 41(2):e35.](https://www.ncbi.nlm.nih.gov/pubmed/23132350)

[Qi L, Liu C, Yuan X, et al. Large-scale prediction of long non-coding RNA functions in a coding–non-coding gene co-expression network[J]. Nucleic Acids Research, 2011, 39(9):3864-3878.](https://www.ncbi.nlm.nih.gov/pubmed/21247874)

[Liao Q, Xiao H, Bu D, et al. ncFANs: a web server for functional annotation of long non-coding RNAs[J]. Nucleic Acids Research, 2011, 39(Web Server issue):W118-W124.](https://www.ncbi.nlm.nih.gov/pubmed/21715382)