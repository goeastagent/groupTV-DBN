
draw_error_graph_over_timepoints <- function(filename_prefix,lambda_seq,tNum){
  
    par(mfrow=c(2,2))
    for(l in lambda_seq){
        error = c()
        total = 0.0
        for(t in 1:tNum){
            filename = paste(filename_prefix,t,sep="_")
            filename = paste(filename,'csv',sep=".")
            
            data = read.csv(filename,sep='\t')
            e = sum(data[paste("X",l,sep="")])
            total = total + e
            error = c(error,e)
        }
        plot(error,type="o",col="blue")
        print(total)
    }
}

draw_error_sum_graph <- function(filename_prefix,lambda_seq,tNum){
    errors = c()
    
    for(l in lambdas){
        total = 0.0
        for(t in 1:tNum){
            filename = paste(filename_prefix,t,sep="_")
            filename = paste(filename,'csv',sep=".")
            
            data = read.csv(filename,sep='\t')
            e = sum(data[paste("X",l,sep="")])
            total = total + e
        }
        errors = c(errors,total)
    }
    
    print(errors)
    plot(errors,type="o",col="red")
}

get_precision <- function(filename1,filename_answer){
    result = read.csv(filename1,sep='\t',header=FALSE)
    answer = read.csv(filename_answer,sep='\t',header=FALSE)

    collect_cnt = 0
    pNum = length(rownames(result))
    for(p in 1:pNum){
        p1 = as.character(result[p,1])
        p2 = as.character(result[p,2])

        aNum = length(rownames(answer))
        for(ap in 1:aNum){
            a1 = as.character(answer[ap,1])
            a2 = as.character(answer[ap,2])
            if(((p1 == a1) && (p2 == a2)) || ((p1 == a2) && (p2 == a1))){
                collect_cnt++
                break
            }
        }
    }
    return(collect_cnt/pNum)
}

get_recall <- function(filename1,filename_answer){
    return(get_precision(filename_answer,filename1))
}

get_f1score <- function(filename1,filename_answer){
    precision = get_precision(filename1,filename_answer)
    recall = get_recall(filename1,filename_answer)
    return(2*precision*recall/(precision+recall))
}

prefix = "v2/result/yeast_simulated_loss"
lambda_seq=seq(from=0.01,to=0.02,by=0.001)
#draw_error_graph_over_timepoints(prefix,c(0.01,0.014,0.018,0.02),21)
#draw_error_sum_graph(prefix,lambda_seq,21)

filename1 = 'v2/network/network0.014_1.tsv'
filename2 = 'v2/network/Yeast-1_goldstandard.tsv'

f1 = get_f1score(filename1,filename2)
print(f1)