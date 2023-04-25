import requests
import pandas as pd
import os
import json
from random import randint
from time import sleep

s = requests.session()
headers = {'user-agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36'}

# List states
url = " https://ejalshakti.gov.in/jjmreport/JJMIndia.aspx/JJM_StateDistrictSearch"
payload = {
    "StCode" : "11",
    "Name" : "1"
}

req = s.post(url, headers = headers, json = payload)
info = req.json()
states_df = pd.DataFrame(info['d'])

# Dont overwrite: was manually edited to inlcude the 'StCode' column
# states_df.to_csv('../../data/scraping/states-list.csv')

req = s.post(url, headers = headers, json = payload)
info = req.json()

dtcode_list = ['4951','4881', '4891','4921','4941','4991','4931','4%3A61','48%3A1','4971','4%3A%3A1','4%3A81','4%3A51','4%3A71','4%3A31','4%3A41','4811','4%3A21','4841','49%3A1','4911','4821','4%3A11','4861','4%3A91','4871','4961','4981','4831','4851']
alphabetsearch_lst = ['B1','C1','D1','E1','F1','G1','H1','I1','J1','K1','L1','M1','N1','O1','P1','Q1','R1','S1','T1','U1','V1','W1','X1','Y1','Z1','%5B1']
villages_df = pd.DataFrame()
url = 'https://ejalshakti.gov.in/jjmreport/JJMIndia.aspx/Bind_search_Village'

#for StCode in "321":    
for DtCode in dtcode_list:
    print(DtCode)
    for letter in alphabetsearch_lst:
        print(letter)
        payload = {
            'DtCode': DtCode,
            'StCode': '321',
            'VillageName': letter
        }
        req = s.post(url, headers = headers, json = payload)
        info = req.json()
        new_village = pd.DataFrame(info['d'])
        if not new_village.empty:
            new_village['DtCode'] = DtCode
            new_village['StCode'] = '321'
            villages_df = pd.concat([villages_df, new_village])

villages_df = villages_df.drop_duplicates()
villages_df.to_csv('../../data/scraping/village-list-odisha.csv')

