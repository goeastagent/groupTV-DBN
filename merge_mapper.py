import pandas as pd




if __name__ == "__main__":
    m1 = pd.read_csv('test.tsv',sep='\t')
    m2 = pd.read_csv('mapper.csv',header=None)

    merged = pd.DataFrame(columns=['gid','gname'])

    for key,entry in m1.iterrows():
        if ',' in entry['gname']:
            for gname in entry['gname'].split(','):
                merged = merged.append({'gid':entry['gid'], 'gname': gname},ignore_index=True)

    for key,entry in m2.iterrows():
        gname = entry[1]
        gid = entry[0]
        if not (merged['gid'] == gid).any():
            merged = merged.append({'gid' : gid, 'gname' : gname},ignore_index=True)
            print "merged"
        if not (merged['gname'] == gname).any():
            merged = merged.append({'gid' : gid, 'gname' : gname},ignore_index=True)
            print "merged"

    merged.to_csv('merged_mapper.tsv',sep='\t',index=None)
