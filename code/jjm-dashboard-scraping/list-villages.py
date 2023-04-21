import requests
import pandas as pd
import os

#create StCode list
stcode_list = ['461','231','211', ]
#create DtCode list
dtcode_list = ['4951','4881','4891','4921','4941','4991','4931','4%3A61','48%3A1','4971','4%3A%3A1','4%3A81','4%3A51','4%3A51','4%3A71','4%3A31','4%3A41','4811','4%3A21','4841','49%3A1','4911','4821','4%3A11','4861','4%3A91','4871','4961','4981','4831','4851']
#create alphabet_search list
alphabetsearch_lst = ['B1','C1','D1','E1','F1','G1','H1','I1','J1','K1','L1','M1','N1','O1','P1','Q1','R1','S1','T1','U1','V1','W1','X1','Y1','Z1','%5B1']
#create empty dataframe
df=pd.DataFrame()
#Define session
s=requests.session()
#Define API url
url_search='https://ejalshakti.gov.in/jjmreport/JJMIndia.aspx/Bind_search_Village'
#Define header for the post request
headers={'user-agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36'}
#Define payload for the request form
data={
    'DtCode': "4951",
    'StCode': "321",
    'VillageName': "B1"
    }
req=s.post(url_search,headers=headers,json=data)


#getdataVillageClick('21','384','404976','0000305249','Odisha','Angul','Abmadara')
#read the data back as json file
j=req.json()
#convert the json file to dataframe
df_new=pd.DataFrame(j['d'])
#append dataframe to other dataframe
df = pd.concat([df,df_new])
#save the dataframe as csv file
df.to_csv('../../data/scraping/village-list.csv')
