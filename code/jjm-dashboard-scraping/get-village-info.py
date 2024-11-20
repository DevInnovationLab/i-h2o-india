import requests
import pandas as pd
import os
from glob import glob

df = pd.DataFrame()
s = requests.session()

url_search='https://ejalshakti.gov.in/jjmreport/JJMVillage_Profile.aspx/Bind_Fhtc_info'
headers={'user-agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36'}

old_data = pd.read_csv('../../data/scraping/village-data-odisha.csv')
villagesCollected = old_data['VillCode']

search_parameters = pd.read_csv('../../data/scraping/odisha-first-villcode.csv')
search_parameters = search_parameters[search_parameters['Collected'] == 0]
search_parameters = search_parameters.reset_index() 

for index, row in search_parameters.iterrows():
    DtCode = row['DtCode']
    StCode = row['StCode']
    VillCode = row['VillCode']
    i = 0
    while i < 15: 
        print(VillCode)
        payloadStCode = str(StCode)
        payloadStCode = payloadStCode.replace('0', '%3A')
        payloadDtCode = str(DtCode)
        payloadDtCode = payloadDtCode.replace('0', '%3A')
        payloadVillCode = str(VillCode)
        payloadVillCode = payloadVillCode.replace('0', '%3A')

        if not payloadVillCode in villagesCollected:
            payload = {
                "Cat" : "11",
                "DtCode11" : payloadDtCode, # This also varies a bit
                "Param" : "11",
                "StCode11" : payloadStCode,
                "SubCat" : "11", 
                "VillCode" : payloadVillCode
            }
            req = s.post(url_search, headers = headers, json = payload)
            info = req.json()
            df_new = pd.DataFrame(info['d'])
            if not df_new.empty:       
                df_new["VillCode"] = payloadVillCode
                df_new['DtCode'] = payloadDtCode
                df_new['StCode'] = StCode
                print('clean data')
                df = pd.concat([df, df_new])
                df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                i = 0
            if df_new.empty:    
                i = i + 1
                print(i)
            VillCode = VillCode + 10
    if not df.empty:
        file = '../../data/scraping/odisha/village-data-' + payloadDtCode + '.csv'
        if os.path.exists(file):
            print('combining with old data')
            df_old = pd.read_csv(file, low_memory=False)
            df_old = df_old.drop_duplicates()
            df = pd.concat([df, df_old])
            df = df.drop_duplicates()
        df.to_csv(file)


files = glob(os.path.join('../../data/scraping/odisha', '*.csv'))

df = pd.DataFrame()
for file in files:
    print(file)
    df_i = pd.read_csv(file)
    # Assumes everyone has same columns
    df = pd.concat((df, df_i))

df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
df = df.drop_duplicates()

village_names = pd.read_csv('../../data/scraping/village-list-odisha.csv')
df = village_names.merge(df, how = 'left', on = 'VillageId')

df.to_csv('../../data/scraping/village-data-odisha.csv')
