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
      updateSelectInput(session,"sitePick",selected=edisDesc$Site_Name[edisDesc$lat==clicklat])
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
      
      choice <- edisDesc$Prj_ID[edisDesc$Site_Name==input$sitePick]
      choiceInd <- grep(choice, names(datUsed))
      
      yearlyG <- as.xts(order.by=as.Date(datUsed[,1]),x=as.numeric(datUsed[,choiceInd]))
      yearlyGavg <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+1])
      yearlyGreg <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+2])
      yearlyGlaw <- as.xts(order.by=as.Date(datUsed[,1]),x=datUsed[,choiceInd+3])
      
      dygraph(cbind(yearlyG,yearlyGavg,yearlyGreg,yearlyGlaw))%>%
        dySeries("..1", label = "Actual Flow",color="black")%>%
        dySeries("..2", label = "Yearly Avg.",color="blue")%>%
        dySeries("..3", label = "Regulation (80%)",color="red",strokePattern="dashed")%>%
        dySeries("..4", label = "Legal (20-40%)",color="blue",strokePattern="dashed")%>%
        dyAxis("y", label = "Flow (cfs)", valueRange = c(0, 1.5*yearlyGavg[1]))%>%
        dyRangeSelector(dateWindow = c(sprintf("%i-01-01",latest), sprintf("%i-12-31",latest)))%>%
        dyLegend(labelsSeparateLines=TRUE)%>%
        dyOptions(fillGraph=TRUE)
    })
    
    #### Text output to display next to map
    output$text1 <- renderText({
      input$sitePick
      sprintf("Current value: %s",  
              rtusgs[rtusgs[,1]==input$sitePick,2])
    })

    #### Text output to explain the overall tool
    output$paraExplain <- renderText({
    "

              The SOLID BLACK line represents actual stream flow measured at the gage.
              The DASHED RED line represents the flow that would remain if water users
              withdraw and consume 80% of the mean annual daily flow. This represents the
              maximum consumption under the definition of safe yield used in the DHEC regulations.
              (cite reg.) Under this scenario, the river will commonly be dry in the summertime.

              The DASHED BLUE line represents minimum instream flows as defined by law.
              Law defines this as 40% of the mean annual daily flow for January - April,
              30% for May - June and December, and 20% for July - November.
              The safe yield is defined in the law as the flow above the minimum instream flow.
              Therefore, the law implies that the purple line would be the minimum flow in the river,
              even after full allocation of the safe yield.

              This comparison can show that the current regulations have often resulted in shortages,
              whereas the legal standards have resulted in much fewer shortages. Select between the Gaged 
              and Extended Unimpaired Flow to show plots from each dataset.  Click a map marker to show
              a popup with more details and to generate a plot for that location, or select the site
              from the drop-down menu.
    
    
    "
      
    })


    #### Data tab tables
    output$edisTable <- renderDataTable({
      input$datPick
            
      if(input$datPick==datList[1]){
        datUsed<-edisGageDat
      }else if(input$datPick==datList[2]){
        datUsed<-edisEUIFDat
      }
      choice <- edisDesc$Prj_ID[edisDesc$Site_Name==input$sitePick]
      choiceInd <- grep(choice, names(datUsed))
      datUsed[(datUsed[,choiceInd]!='NA'),c(1,choiceInd:(choiceInd+3))]
    }) 
  output$descTable <- renderDataTable({
    edisDesc[,1:8]
  }) 
})