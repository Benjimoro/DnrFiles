#Clemson DNR yearly flow app - Global
#
#Author: Ben B. Warner
#Last mod: 8/2/2016

#server: dnrproject.cloudapp.net username: azureuser pwd: Dnr2016

library(shiny)
library(RODBC)
library(varhandle)
library(xts)
library(zoo)

# dbhandle <- odbcConnect("MSSQL","usgssql","Usgs2016")
# dbhandle2 <- odbcConnect("MSSQL2","usgssql","Usgs2016")
dbhandle <- odbcDriverConnect('driver={SQL Server};
                              server=crjtx9reyb.database.windows.net;
                              uid=usgssql;
                              pwd=Usgs2016;
                              database=dnr-edisto;
                              ')                      
dbhandle2 <- odbcDriverConnect('driver={SQL Server};
                              server=crjtx9reyb.database.windows.net;
                              uid=usgssql;
                              pwd=Usgs2016;
                              database=usgssql;
                              ')                      

rtusgs <- sqlQuery(dbhandle2, 'select * from [usgssql].[dbo].[usgsFlow]')

edisGageDat <- sqlQuery(dbhandle, 'select * from [dnr-edisto].[dbo].[edistoDataGage] ORDER BY date')

edisEUIFDat <- sqlQuery(dbhandle, 'select * from [dnr-edisto].[dbo].[edistoDataEUIF] ORDER BY date')

edisDesc <- unfactor(sqlQuery(dbhandle, 'select * from [dnr-edisto].[dbo].[dnr-GageTable-desc]'))
edisDesc<- edisDesc[edisDesc$Prj_ID!="",]

for(i in 1:length(edisDesc$Active)){
  if(edisDesc[i,5]=="Inactive"){
    edisDesc$color[i]="red"
  }
  else if(edisDesc[i,5]=="Active"){
    edisDesc$color[i]="blue"
  }
}

datList <- c("Gaged","Extended Unimpaired Flow")

odbcCloseAll()
