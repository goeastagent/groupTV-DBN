source('GroupLassoBuilder.R')
source('GroupLassoEval.R')

output_prefix = 'v2/yeast_simulated'
filename_data = "v2/yeast_simulated.data.tsv"
filename_timep = "v2/yeast_simulated.time_points.tsv"
filename_gid = 'v2/yeast_simulated.gid.tsv'
filename_group = 'v2/yeast_simulated.group.txt'
output_prefix = 'v2/result/yeast_simulated'

kernel_height <<- 2000

time_points = read.csv2(filename_timep,sep='\t',header=FALSE)

data = read.csv2(filename_data,sep='\t',header=FALSE)      # n by p matrix
data = as.matrix(data)
class(data) = "numeric"

time_points <<- c(time_points[[1]])

gids = read.csv2(filename_gid,sep='\t',header=FALSE)
gids <<- c(gids[[1]])

group_list = build_group_list(filename_group)

tNum = length(time_points)
pNum = length(gids)

lambda_seq=seq(from=0.01,to=0.02,by=0.001)

###############################################################


groupLasso(tNum,pNum,data,0.014,group_list,output_prefix)
