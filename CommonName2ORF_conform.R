library('org.Sc.sgd.db')

## This script is helper script to check if given yeast common name could be converted into ORF
## Genes provided by SGD Slim Mapper are usually yeast common name, but
## genes in gene expression data are ORF.
## Before mapping yeast common name to ORF, this script check if given yeast common names are fully convertible
## The file format should be listed in one column. 
## e.g.
## CDC15
## RDH54
## MUM2
## 
## Mapper is from YeastMine (TODO)

mapper = read.csv('v2/results.tsv',header=FALSE,sep='\t')


conform <- function(filename){
    print("===CommonName To ORF Conformation===")
      
    genenames = read.csv(filename,header=FALSE)
    print("printing genes unable to be converted...")
    for(genename in as.character(genenames[['V1']])){
        print(mapper[mapper['V2'] == genename])
        if(length(mapper[mapper['V1'] == genename]) == 0 &&
            length(mapper[mapper['V2'] == genename]) == 0){
            print(genename)
        }
    }
    print("Done")
}

autoMap <- function(g){
  if(length(mapper[mapper['V1'] == g]) != 0){
    return(g)  
  }else{
    return(mapper[mapper['V2'] == g][1])
  }
  print("DONE")
}

