source('CommonName2ORF_conform.R')

filename_gid= "v2/yeast_simulated.gid.tsv"
filename_group = "v2/slimMapperResult.13392.csv"
filename_output = "v2/yeast_simulated.group.txt"

fileconn = file(filename_output,'w')

group = read.csv(filename_group,sep='\t')
gids = read.csv(filename_gid,header=FALSE)

l = length(rownames(group))

for(i in 1:l){
    if(group[i,5] == 'none'){
        next
    }
    genes = strsplit(as.character(group[i,5]),',')
   
    gLen = length(genes[[1]])
    gNums = which(gids[1] == autoMap(genes[[1]][1]))
    if(gLen != 1){
      for(j in 2:gLen){
          g = autoMap(genes[[1]][j])
          gNums = paste(gNums,which(gids[1] == g),sep=',')
      }
    }else{
      gNums = paste("",gNums,sep='')
    }
    print(gNums)
    writeLines(gNums,con=fileconn,sep='\n')
}

close(fileconn)
