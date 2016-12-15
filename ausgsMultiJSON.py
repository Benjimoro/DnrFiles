# -*- coding: utf-8 -*-
"""
Import discharge, flowrate, and timeseries datasets.
Created on Tue Jul 05 09:22:30 2016

@author: bbwarne
"""
from azure.storage.blob import BlockBlobService

import requests
#import datetime
#today = datetime.date.today()
#lastmonth = today.month-1
#rTS = requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&stateCd=sc&startDT={0}-{2}-{1}&endDT={0}-{3}-{1}&parameterCd=00060,00065'.format(today.year,today.day,lastmonth,today.month))
r =requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&stateCd=sc&parameterCd=00060,00065')
#r = requests.get('http://waterservices.usgs.gov/nwis/iv/?format=json,1.1&indent=on&sites=02186000&parameterCd=00060,00065')

#tsdata = rTS.json()['value']['timeSeries']
data = r.json()['value']['timeSeries']


import json
with open('usgsDat.json', 'w') as outfile:
    json.dump(data, outfile, sort_keys=True, indent=2, separators=(',',': '))
#with open('usgsDatTS.json', 'w') as outfile:
#    json.dump(tsdata, outfile, sort_keys=True, indent=2, separators=(',',': '))
    
block_blob_service = BlockBlobService(account_name='usgsstorage', account_key='KASxRSxKQscbwVvd/zFtln+9wspqq/gae4+8V57xPLodmZvg9Wx29rAOa8a2a/TBgNy2/69MiWoaGpzaCH+MWQ==')

from azure.storage.blob import ContentSettings
block_blob_service.create_blob_from_path(
    'usgspulled',
    'blockblobJSON',
    'usgsDat.json',
    content_settings=ContentSettings(content_type='text/json')
            )
#block_blob_service.create_blob_from_path(
#    'usgspulled',
#    'blockblobJSONts',
#    'usgsDatTS.json',
#    content_settings=ContentSettings(content_type='text/json')
#            )            
            
#import pandas as pd

#test=pd.read_json('usgsDat.json')
test = data
#testTS = tsdata
heightValList = []
flowValList = []
#tsValList = []

#for i in range(0,len(testTS)):
#    for j in range(0,len(testTS[i]['values'][0]['value'])):
#        tsValList.append({u'sitename': testTS[i]['sourceInfo']['siteName'],
#                          u'value': testTS[i]['values'][0]['value'][j]['value'],
#                          u'units': testTS[i]['variable']['unit']['unitCode'],
#                          u'description': testTS[i]['variable']['variableDescription'],
#                          u'dateTime':testTS[i]['values'][0]['value'][j]['dateTime']
#                          })


for i in range(0,len(test)):
    if (test[i]['values'][0]['value'][0]['value'] != test[0]['variable']['noDataValue']):
        if(test[i]['variable']['unit']['unitCode']== u'ft'):
            heightValList.append({u'sitename': test[i]['sourceInfo']['siteName'],
                      u'value': test[i]['values'][0]['value'][0]['value'], 
                      u'units': test[i]['variable']['unit']['unitCode'], 
                      u'description':test[i]['variable']['variableDescription'], 
                      u'lat': test[i]['sourceInfo']['geoLocation']['geogLocation']['latitude'], 
                      u'long': test[i]['sourceInfo']['geoLocation']['geogLocation']['longitude']
                      })
    
    if (test[i]['values'][0]['value'][0]['value'] != test[0]['variable']['noDataValue']):                  
        if(test[i]['variable']['unit']['unitCode']== u'ft3/s'):
            flowValList.append({u'sitename': test[i]['sourceInfo']['siteName'],
                      u'value': test[i]['values'][0]['value'][0]['value'], 
                      u'units': test[i]['variable']['unit']['unitCode'], 
                      u'description':test[i]['variable']['variableDescription'], 
                      u'lat': test[i]['sourceInfo']['geoLocation']['geogLocation']['latitude'], 
                      u'long': test[i]['sourceInfo']['geoLocation']['geogLocation']['longitude']
                      })
                      
#heightValList=pd.DataFrame(heightValList) 
#heightValList.to_csv('usgsheightValues.csv',header=False,index=False)
#
#flowValList=pd.DataFrame(flowValList) 
#flowValList.to_csv('usgsflowValues.csv',header=False,index=False)
                      
import csv

fieldNam = [u'sitename',u'value',u'units',u'description',u'lat',u'long']
#fieldNamTS = [u'sitename',u'value',u'units',u'description',u'dateTime']
with open('usgsheightValues.csv', 'w') as heightfile:
    wr = csv.DictWriter(heightfile,fieldnames=fieldNam)
    wr.writerows(heightValList)
with open('usgsflowValues.csv', 'w') as flowfile:
    wr = csv.DictWriter(flowfile,fieldnames=fieldNam)
    wr.writerows(flowValList)
#with open('usgsTSvalues.csv', 'w') as tsfile:
#    wr = csv.DictWriter(tsfile,fieldnames=fieldNamTS)
#    wr.writerows(tsValList)    
    

block_blob_service.create_blob_from_path(
    'usgspulled',
    'heightblobCSV',
    'usgsheightValues.csv',
    content_settings=ContentSettings(content_type='text/csv')
            )
block_blob_service.create_blob_from_path(
    'usgspulled',
    'flowblobCSV',
    'usgsflowValues.csv',
    content_settings=ContentSettings(content_type='text/csv')
            )
#block_blob_service.create_blob_from_path(
#    'usgspulled',
#    'tsblobCSV',
#    'usgsTSvalues.csv',
#    content_settings=ContentSettings(content_type='text/csv')
#            )