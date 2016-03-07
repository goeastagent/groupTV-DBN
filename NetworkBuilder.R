

filename_gids = 'v2/yeast_simulated.gid.tsv'
tNum = 21
pNum = 500
lambda = 0.014
gids = read.csv(filename_gids,sep='\t',header=FALSE)


filename_graph = 'v2/result/yeast_simulated.graph'
#filename_graph = paste(filename_graph,lambda,sep='.')


output_prefix = 'v2/network/network'
output_prefix = paste(output_prefix,lambda,sep='')

buildNetworkEdge <- function(){
    gids = read.csv(filename_gids,sep='\t',header=FALSE)

    for(t in 1:tNum){
        output = paste(output_prefix,t,sep="_")
        output = paste(output,'tsv',sep='.')
        fileconn = file(output,'w')
        filename = paste(filename_graph,t,sep='_')
        filename = paste(filename,'csv',sep='.')
        print(filename)
        network = read.csv(filename,sep='\t',header=FALSE)

        for(p1 in 1:pNum){
            p1name = as.character(gids[[1]][p1])
            vs = which(network[p1,] != 0)
            for(p2 in vs){
                if(p1 == p2)
                    next
                p2name = as.character(gids[[1]][p2])
                line = paste(paste(p1name,p2name,sep='\t'),1,sep='\t')
                writeLines(line,con=fileconn,sep='\n')
            }
        }
        
        close(fileconn)
    }
}


buildNetworkEdge()
