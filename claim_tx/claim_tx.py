import pandas as pd

# match county name with fips code
county = pd.read_csv('county.csv')
fips = pd.read_csv('fips.csv',header=None,dtype={1:str,2:str})
f = fips[[1,2,3]]
f['fips'] = f[1]+f[2]
f['county'] = f[3].apply(lambda x: x[0:-7].upper()) 
f = f[['fips','county']]
cf = pd.merge(county,f,on = ['county','county'],how='left')
cf['fips'].fillna({61:'48123',159:'48307',160:'48309',161:'48311'},inplace=True,axis=0)
cf.to_csv('county_fips.csv')

# read closed claims 
d2006 = pd.read_csv('closed2006.csv')
d2007 = pd.read_csv('closed2007.csv')
d2008 = pd.read_csv('closed2008.csv')
d2009 = pd.read_csv('closed2009.csv')
d2010 = pd.read_csv('closed2010.csv')
d2011 = pd.read_csv('closed2011.csv')
d2012 = pd.read_csv('closed2012.csv')
tapub = pd.concat([d2006,d2007,d2008,d2009,d2010,d2011,d2012])

# drop non texas
tapub = tapub[(tapub['Q6B']!=299)]
# keep medicare/medicaid
tapub = tapub[(tapub['Q14C4']=='Y')]
tapub = tapub[['Q1A','Q6B']]
tapub.columns = ['date','code']
tapub['year'] = tapub['date'].apply(lambda x: str(x).split('/')[-1])
tapub['year'] = tapub['year'].apply(lambda x: int('19'+x) if int(x) > 20 else int('20'+x))
# match with fips code
tx = pd.merge(tapub,cf,on = ['code','code'],how='inner')
# keep only year 2006 - 2012, and columns year, fips
malpracticeTX = tx[(tx['year']>=2006)][['year','fips','code']]
count = pd.DataFrame({'count' : malpracticeTX.groupby(['fips','year']).size()}).reset_index()
count.to_csv('malpracticeTX.csv')