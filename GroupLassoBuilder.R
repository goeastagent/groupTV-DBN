library(grpregOverlap)
library(grpreg)

## This script implements group lasso with overlap
## The function grpregOverlap in the library "grpregOverlap" is used in training coefficients
## Building time-varying Bayesian network requires columns of gene expression data weighted
## to consider them as another gene expression data for training. That is, each columns should be reweighted
## over all iterations.
##
## Given time-series gene expression data, this script makes each columns reweighted on iterations,
## then run grpregOverlap, and merge the coefficients


## Building Time-Varying Network (Group Lasso)
groupLasso <- function(tNum,pNum,data,lambda,group_list,output_prefix){
    for(tStar in 1:tNum){
        w = get_weight_vector(tStar)
        w = sqrt(w)
        X = build_weighted_Xmatrix(data[-1,],w)
      
        for(p in 1:pNum){
            y = as.matrix(data[1:tNum-1,p]*w)
            
            fit = grpregOverlap(X,y,group_list,penalty='grLasso',lambda=lambda)
            
            if(p == 1){
                A = fit$beta[-1]
                loss = fit$loss
            }
            else{
                A = cbind(A,fit$beta[-1])
                loss = c(loss,fit$loss)
            }
        }

        print(paste(tStar,"Done",sep=":"))
        output = output_prefix
        output = paste(output,"graph",sep=".")
        output = paste(output,lambda,sep="")
        output = paste(output,tStar,sep="_")
        output = paste(output,'csv',sep='.')
        write.table(A,file=output,row.names=FALSE,col.names=FALSE,sep='\t')
        output = output_prefix
        output = paste(output,"loss",sep=".")
        output = paste(output,lambda,sep="")
        output = paste(output,tStar,sep="_")
        output = paste(output,'csv',sep='.')
        write.table(loss,file=output,row.names=FALSE,col.names=FALSE,sep='\t')
    }
}

## Building Time-Varying Network (Group Lasso)
## Obtaining loss values only
groupLasso_lossonly<- function(tNum,pNum,data,group_list,lambda_seq,output_prefix){
    for(tStar in 1:tNum){
        w = get_weight_vector(tStar)
        w = sqrt(w)
        X = build_weighted_Xmatrix(data[-1,],w)
        for(p in 1:pNum){
            y = as.matrix(data[1:tNum-1,p]*w)
            
            fit = grpregOverlap(X,y,group_list,penalty='grLasso',lambda=lambda_seq)

            if(p == 1){
                A = fit$loss
            }
            else{
                A = rbind(A,fit$loss)
            }
        }
        
        colnames(A) = lambda_seq
        
        print(paste(tStar,"Done",sep=":"))
        output = output_prefix
        output = paste(output,'loss',sep='_')
        output = paste(output,tStar,sep="_")
        output = paste(output,'csv',sep='.')
        write.table(A,file=output,row.names=FALSE,sep='\t') 
    }
}

lasso_lossonly <- function(tNum,pNum,data){
    lambda_seq=seq(from=0.01,to=1,by=0.01)
    for(tStar in 1:tNum){    
        w = get_weight_vector(tStar)
        w = sqrt(w)
        X = build_weighted_Xmatrix(data[-1,],w)
        
        for(p in 1:pNum){
            y = as.matrix(data[1:tNum-1,p]*w)
            fit = grpreg(X,y,group=1:ncol(X),penalty='grLasso',lambda=lambda_seq)
            
            if(p == 1){
                A = fit$loss
            }
            else{
                A = rbind(A,fit$loss)
            }
            print(p)
        }
        
        colnames(A) = lambda_seq
        
        print(paste(tStar,"Done",sep=":"))
        output = 'loss_result/lasso_loss_lambda(0.01x)'
        output = paste(output,tStar,sep="_")
        output = paste(output,'csv',sep='.')
        write.table(A,file=output,row.names=FALSE,sep='\t') 
    }
}

build_trivial_group_list <- function(pNum){
    group_list = list()
    gr = 'grp'
    cnt = 1
    for(p in 1:pNum){
        group_list[[paste(gr,cnt,sep="")]] = c(p)
        cnt = cnt + 1
    }
    
    return(group_list)
}

## 
build_group_list <- function(filename){
    group = read.csv(filename,sep='\t',header=FALSE)
    gr = 'grp'
    cnt = 1
    group_list = list()
    for(g in group[[1]]){
        l = c()
        for(token in strsplit(g,',')[[1]]){
            g = as.numeric(token)
            l = c(l,g)
        }

        group_list[[paste(gr,cnt,sep='')]] = l
        cnt = cnt + 1
    }

    return(group_list)
}

## This function builds weighted matrix
## X (p by n)
## w (1 by t-1)
build_weighted_Xmatrix <- function(X,w){
    nrow = dim(X)[1]
    wX = X
    for(t in 1:nrow){
        wX[t,] = wX[t,]*w[t]
    }
    return(wX)
}


get_kernel_sum <- function(tStar){
    ksum = 0.0
    for(t in time_points){
        ksum = ksum + get_kernel_value(tStar-t)
    }

    return(ksum)
}

get_kernel_value <- function(t){
    return(exp(-(t^2)/kernel_height))
}

## Getting weight vector given tStar
get_weight_vector <- function(tStar){
    w = c()
    
    for(t in time_points){
        if(t == 0)                      # skip building weighted value for the first time point
            next
        w = c(w,get_kernel_value(t-tStar)/get_kernel_sum(tStar))
    }
    return(w)
}




## parameter setting
filename_data = "v2/yeast_simulated.data.tsv"
filename_timep = "v2/yeast_simulated.time_points.tsv"
filename_gid = 'v2/yeast_simulated.gid.tsv'
filename_group = 'v2/yeast_simulated.group.txt'
output_prefix = 'v2/result/yeast_simulated'
kernel_height = 2000


time_points = read.csv2(filename_timep,sep='\t',header=FALSE)

data = read.csv2(filename_data,sep='\t',header=FALSE)      # n by p matrix
data = as.matrix(data)
class(data) = "numeric"

time_points = c(time_points[[1]])

gids = read.csv2(filename_gid,sep='\t',header=FALSE)
gids = c(gids[[1]])

group_list = build_group_list(filename_group)

tNum = length(time_points)
pNum = length(gids)

lambda_seq=seq(from=0.01,to=0.02,by=0.001)

groupLasso(tNum,pNum,data,0.014,group_list,output_prefix)
#groupLasso_lossonly(tNum,pNum,data,group_list,lambda_seq,output_prefix)
                                        #lasso_lossonly(tNum,pNum,data)
