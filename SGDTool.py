import pandas as pd



class SGDTool:
    def __init__(self):
        self.mapper = pd.read_csv('mapper.csv')


    def conform_MAPPER(self,sgd_filename):
        group = pd.read_csv(sgd_filename,sep='\t')
        l = []
        for g in group['Gene(s)']:
            if g == 'none':
                continue
            for e in g.split(','):
                l.append(e)

        pd.DataFrame(l).to_csv('test.csv',sep='\t',index=None)
                
                

    # This function provides gene name( or gene ID) list to run Go Mapper Slim Tool
    # test example is 'fitnorm.gLoess2Dt25s04.txt'
    def make_list(self,filename):
        data = pd.read_csv(filename,sep='\t')
        gid_list = data['gid']
        gid_list = gid_list[5:] # remove first 5 rows that are not gene expression rows.

        gid_list.to_csv('gid_list.txt',header=False,sep='\t',index=None)


    # This function parses the file resulted from Go Mapper Slim Tool
    # Each rows in the file contains gene sets which are grouped based on
    # a biological measure. 
    def parse_GOMapper_file(self,filename):
        result = pd.read_csv(filename,sep='\t')
        group_gene = []

        for key,entry in result.iterrows():
            genes = entry['Gene(s)']
            if genes == 'none':
                continue

            genes = genes.split(',')
            group = []
            for e in genes:
                group.append(e)
            group_gene.append(group)
        return group_gene

    # This function builds group matrices for group lasso
    # Param 1: result_filename is the path of the file resulted from Go Mapper Slim Tool
    # Param 2: the file path of Time-Varying Gene Expression Data
    def build_group_matrices(self,result_filename,gene_filename,output_filename):
        group_genes = self.parse_GOMapper_file(result_filename)
        gene_expression = pd.read_csv(gene_filename,sep='\t')
        data = gene_expression.copy()
        
        
        print "==========Gene Mapping Analysis==========="
        l = []
        for group in group_genes:
            for g in group:
                l.append(g)
        ignore_genes = s.mapping_analysis(data,l)
        print "Analysis Done.."

            
        # build row vector
        group_list = pd.DataFrame()
        zeros = [ 0 for i in range(len(group_genes))]
        group_list['group'] = zeros

        count = 0
        for key,group in enumerate(group_genes):
            # parsed depending on file format
            for g in group:
                if g in ignore_genes:
                    continue

                # if any(data['gname'] == g):
                #     index = data[data['gname'] == g].index[0]
                if any(data['gid'] == g):
                    index = data[data['gid'] == g].index[0]
                    
                # elif any(self.mapper['gid'] == g):
                #     row = self.mapper[self.mapper['gid'] == g]
                #     for k,entry in row.iterrows():
                #         if any(data['gid'] == entry['gname']):
                #             index = data[data['gid'] == entry['gname']].index[0]
                #             break
                #         if any(data['gname'] == entry['gname']):
                #             index = data[data['gname'] == entry['gname']].index[0]
                #             break
                # elif any(self.mapper['gname'] == g):
                #     row = self.mapper[self.mapper['gname'] == g]
                #     for k,entry in row.iterrows():
                #         if any(data['gid'] == entry['gid']):
                #             index = data[data['gid'] == entry['gid']].index[0]
                #             break
                #         if any(data['gname'] == entry['id']):
                #             index = data[data['gname'] == entry['gid']].index[0]
                #             break
                else:
                    print "Something's wrong"
                    break
                   
                if group_list['group'][key] == 0:
                    group_list['group'][key] = str(index)
                else:
                    group_list['group'][key] = str(group_list['group'][key]) + "," + str(index)

            print count,"Done"
            count += 1
        group_list.to_csv(output_filename,sep='\t',index=None,header=False)


    # This function checks if there is possible gene id, which is corresponding to proper gene name (TODO)
    # 
    def mapping_analysis(self,data,group_genes):
        ignore_genes = []

        for g in group_genes:
            # if any(data['gname'] ==g):
            #     continue
            if any(data['gid'] == g):
                continue
            if any(self.mapper['gid'] == g):
                row = self.mapper[self.mapper['gid'] == g]
                flag = 0
                for k,e in row.iterrows():
                    if any(data['gid'] == e['gname']):
                        flag =1 
                        break
                    # if any(data['gname'] == e['gname']):
                    #     flag = 1
                    #     break

                if flag == 1:
                    continue
            # if any(self.mapper['gname'] == g):
            #     row = self.mapper[self.mapper['gname'] == g]
            #     flag = 0
            #     for k,e in row.iterrows():
            #         if any(data['gid'] == e['gid']):
            #             flag = 1
            #             break
            #         if any(data['gname'] == e['gid']):
            #             flag = 1
            #             break
            #     if flag == 1:
            #         continue

            # print "GENE :",g,"Failed to map"
            ignore_genes.append(g)
        print "Total",len(ignore_genes),"genes unable to map"

        return ignore_genes

    # file from GO slim Mapper
    def overlap_test(self,filename):
        group = self.parse_GOMapper_file(filename)
        l = []
        key_l = []
        for key,g in enumerate(group):
            for gene in g:
                if any(self.mapper['gid'] == gene):
                    gid = gene
                # elif any(self.mapper['gname'] == gene):
                #     gid = self.mapper[self.mapper['gname'] == gene].iloc[0]['gid']
                else:
                    continue

                if gid in l:
                    index = l.index(gid)
                    print "Group",key,"Overlap detected:",key,"and",key_l[index]
                    break
                else:
                    l.append(gid)
                    key_l.append(key)

    # filter out genes that are not annotated
    def geneset_filtering(self,filename_data,filename_group):
        data = pd.read_csv(filename_data)
        group = open(filename_group)

        

if __name__ == "__main__":
    s = SGDTool()
    #print "building group matrix....."
    #s.build_group_matrices('v2/slimMapperResult.13392.csv','v2/yeast_simulated.tsv','v2/fitnorm.grouping.csv')
    #print s.parse_GOMapper_file('v2/slimMapperResult.26143.csv')


    s.conform_MAPPER('v2/slimMapperResult.13392.csv')
