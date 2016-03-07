import pandas as pd

# This script is helper class for building network edges, given .csv files,
# which is n-by-n adjacent matrix
# 

class NetworkBuilder:
    def __init__(self):
        self.data = None
        self.vertices = None

    def loaddatafile(self,filename_graph):
        self.data = pd.read_csv(filename_graph,sep='\t',header=None)
        
    def loadgfile(self,filename_vertices):
        self.vertices = pd.read_csv(filename_vertices,sep='\t',header=None)[0]

    def build_network_edge(self,output):
        if type(self.data) == type(None):
            print "You should load adjacency matrix first"
            return

        f = open(output,'w')
        for key,entry in self.data.iterrows():
            gids = entry[entry != 0]
            for i in  gids.index:
                f.write(self.vertices[key] + '\t' + self.vertices[i] + '\t' + '1\n')
        
        f.close()

    def build_network_union(self,filenames,output):
        f = open(output,'w')
        out = pd.read_csv(filenames[0],sep='\t',header=None)
        filenames = filenames[1:]
        
        for filename in filenames:
            data = pd.read_csv(filename,sep='\t',header=None)
            out = out.append(data)

        print out.shape
        out.drop_duplicates()
        print out.shape

        out.to_csv(output,index=False,header=False,sep='\t')
                
            
            
        


if __name__ == "__main__":
    n = NetworkBuilder()
    n.loadgfile('fitnorm.gids.csv')

    lda = 0.05

    filename='result/network_' + str(lda) + '_'
    output = 'graph_representation/network_' + str(lda) + '_'

    filenames = [ "graph_representation/network_0.01_" + str(i) + ".tsv"  for i in range(1,26)]

    # for i in range(1,26):
    #     n.loaddatafile(filename+str(i) + '.csv')        
    #     n.build_network_edge(output+str(i)+'.tsv')

    n.build_network_union(filenames,"graph_representation/network_0.01_integrated.txt")
