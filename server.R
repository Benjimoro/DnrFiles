#Clemson DNR yearly flow app - Server
#
#Author: Ben B. Warner
#Last mod: 8/2/2016

library(shiny)
library(leaflet)
library(dygraphs)

shinyServer(
  function(input, output, session) {
    #### Create the Leaflet map
    output$map<-renderLeaflet({
      map <- leaflet()%>%
        addTiles(options=tileOptions(minZoom=5))%>%
        addCircleMarkers(lng = edisDesc$long, lat = edisDesc$lat, 
                         popup = sprintf("ID: %s Num: %s <br>Name: %s <br>Status: %s",
                                         edisDesc$Prj_ID,
                                         edisDesc$Site_Number,
                                         edisDesc$Site_Name,
                                         edisDesc$Active),
                   options = markerOptions(riseOnHover=T,opacity=0.8),color=edisDesc$color)
    })
    ####Observe 
    observeEvent(input$map_marker_click,{
      clicklat <- input$map_marker_click$lat
      clicklong <- input$map_marker_click$lng
      updateSelectInput(session,"sitePick",selected=edisDesc$Prj_ID[edisDesc$lat==clicklat])
#       print(clickedMarkerlong)
    })
    
    #### Create dynamic plot
    output$flowPlot<- renderDygraph({
      input$sitePick
      
      if(input$datPick==datList[1]){
        datUsed<-edisGageDat
      }else if(input$datPick==datList[2]){
        datUsed<-edisEUIFDat
      }
      
      earliest<-min(as.numeric(format(as.Date(datUsed[,1]),'%Y')))
      latest<-max(as.numeric(format(as.Date(datUsed[,1]),'%Y')))
      
      choice <- input$sitePick
      choiceInd <- grep(choice, names(datUsed))
      
      yearlyG <- as.xts(order.by=as.Date(datUsed[,1]),x=as.numeric(datUsed[,choiceInd]))
      yearlyGavg <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+1])
      yearlyGreg <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+2])
      yearlyGlaw <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+3])
      
      dygraph(cbind(yearlyG,yearlyGavg,yearlyGreg,yearlyGlaw))%>%
        dySeries("..1", label = "Actual Flow")%>%
        dySeries("..2", label = "Yearly Avg.")%>%
        dySeries("..3", label = "Regulation (80%)")%>%
        dySeries("..4", label = "Law (20-40%)")%>%
        dyAxis("y", label = "Flow (cfs)", valueRange = c(0, 1.5*yearlyGavg[1]))%>%
        dyRangeSelector(dateWindow = c(sprintf("%i-01-01",latest), sprintf("%i-12-31",latest)))
    })
    
    #### Text output to display next to map
    output$text1 <- renderText({
      input$sitePick
      sprintf("Current value: %s",  
              rtusgs[rtusgs[,1]==edisDesc[edisDesc[,2]==input$sitePick,3],2])
    })


    #### Data tab tables
    output$edisTable <- renderDataTable({
      input$datPick
            
      if(input$datPick==datList[1]){
        datUsed<-edisGageDat
      }else if(input$datPick==datList[2]){
        datUsed<-edisEUIFDat
      }
      choice <- input$sitePick
      choiceInd <- grep(choice, names(datUsed))
      datUsed[(datUsed[,choiceInd]!='NA'),c(1,choiceInd:(choiceInd+3))]
    }) 
  output$descTable <- renderDataTable({
    edisDesc[,1:8]
  }) 
})