# -*- coding: utf-8 -*-
"""
Import USGS json from url
Created on Thu Jun 09 12:51:02 2016

@author: bbwarne
"""
from azure.storage.blob import BlockBlobService

import requests
r =requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&stateCd=sc&parameterCd=00060,00065')
#r = requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&sites=02186000&parameterCd=00060,00065')
data = r.json()['value']['timeSeries']

import json
with open('usgsDat.json', 'w') as outfile:
    json.dump(data, outfile, sort_keys=True, indent=2, separators=(',',': '))

block_blob_service = BlockBlobService(account_name='usgsstorage', account_key='KASxRSxKQscbwVvd/zFtln+9wspqq/gae4+8V57xPLodmZvg9Wx29rAOa8a2a/TBgNy2/69MiWoaGpzaCH+MWQ==')

from azure.storage.blob import ContentSettings
block_blob_service.create_blob_from_path(
    'usgspulled',
    'blockblobJSON',
    'usgsDat.json',
    content_settings=ContentSettings(content_type='text/json')
            )
import pandas as pd

test=pd.read_json('usgsDat.json')
valueList = []

for i in range(0,len(test)):
    if (test['values'][i][0]['value'][0]['value'] != test['variable'][1]['noDataValue']):
        valueList.append({u'sitename': test['sourceInfo'][i]['siteName'],
                      u'value': test['values'][i][0]['value'][0]['value'], 
                      u'units': test['variable'][i]['unit']['unitCode'], 
                      u'description':test['variable'][i]['variableDescription'], 
                      u'lat': test['sourceInfo'][i]['geoLocation']['geogLocation']['latitude'], 
                      u'long': test['sourceInfo'][i]['geoLocation']['geogLocation']['longitude']})

valueList=pd.DataFrame(valueList) 

valueList.to_csv('usgsValues.csv',header=False,index=False)

block_blob_service.create_blob_from_path(
    'usgspulled',
    'blockblobCSV',
    'usgsValues.csv',
    content_settings=ContentSettings(content_type='text/csv')
            )
