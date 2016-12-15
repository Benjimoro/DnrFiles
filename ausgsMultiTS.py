# -*- coding: utf-8 -*-
"""
Created on Fri Jul 08 14:13:23 2016

@author: bbwarne
"""
from azure.storage.blob import BlockBlobService
from azure.storage.blob import ContentSettings

import requests
import datetime
today = datetime.date.today()
lastmonth = today.month-1
rTS = requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&stateCd=sc&startDT={0}-{2}-{1}&endDT={0}-{3}-{1}&parameterCd=00060,00065'.format(today.year,today.day,lastmonth,today.month))

tsdata = rTS.json()['value']['timeSeries']

import json

with open('usgsDatTS.json', 'w') as outfile:
    json.dump(tsdata, outfile, sort_keys=True, indent=2, separators=(',',': '))
    
block_blob_service = BlockBlobService(account_name='usgsstorage', account_key='KASxRSxKQscbwVvd/zFtln+9wspqq/gae4+8V57xPLodmZvg9Wx29rAOa8a2a/TBgNy2/69MiWoaGpzaCH+MWQ==')

block_blob_service.create_blob_from_path(
    'usgspulled',
    'blockblobJSONts',
    'usgsDatTS.json',
    content_settings=ContentSettings(content_type='text/json')
            )     
testTS = tsdata
tsFlowValList = []
tsHeightValList = []

for i in range(0,len(testTS)):
    for j in range(0,len(testTS[i]['values'][0]['value'])):
        if(testTS[i]['variable']['unit']['unitCode']== u'ft'):
            tsHeightValList.append({u'sitename': testTS[i]['sourceInfo']['siteName'],
                          u'value': float(testTS[i]['values'][0]['value'][j]['value']),
                          u'units': testTS[i]['variable']['unit']['unitCode'],
                          u'description': testTS[i]['variable']['variableDescription'],
                          u'dateTime':testTS[i]['values'][0]['value'][j]['dateTime']
                          })
    
        if(testTS[i]['variable']['unit']['unitCode']== u'ft3/s'):
            tsFlowValList.append({u'sitename': testTS[i]['sourceInfo']['siteName'],
                          u'value': float(testTS[i]['values'][0]['value'][j]['value']),
                          u'units': testTS[i]['variable']['unit']['unitCode'],
                          u'description': testTS[i]['variable']['variableDescription'],
                          u'dateTime':testTS[i]['values'][0]['value'][j]['dateTime']
                          })

import csv

fieldNamTS = [u'sitename',u'value',u'units',u'description',u'dateTime']

with open('usgsTSFvalues.csv', 'w') as tsFfile:
    wr = csv.DictWriter(tsFfile,fieldnames=fieldNamTS)
    wr.writerows(tsFlowValList)
with open('usgsTSHvalues.csv', 'w') as tsHfile:
    wr = csv.DictWriter(tsHfile,fieldnames=fieldNamTS)
    wr.writerows(tsHeightValList)
    
block_blob_service.create_blob_from_path(
    'usgspulled',
    'tsfblobCSV',
    'usgsTSFvalues.csv',
    content_settings=ContentSettings(content_type='text/csv')
            )
block_blob_service.create_blob_from_path(
    'usgspulled',
    'tsHblobCSV',
    'usgsTSHvalues.csv',
    content_settings=ContentSettings(content_type='text/csv')
            )


