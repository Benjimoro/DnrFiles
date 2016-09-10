#Clemson DNR yearly flow app - UI
#
#Author: Ben B. Warner
#Last mod: 8/2/2016

library(shiny)
library(leaflet)
library(dygraphs)

shinyUI(
  fluidPage(title= "DNR Basin Flow Allowances",
          sidebarPanel(width = 6,
            tabsetPanel(
              tabPanel("Main Menu",
                       fluidRow(column(6,
                                       selectInput("datPick", strong("Select Data Table:"),
                                                   datList,
                                                   selected = datList[1])),
                                column(6,
                                       selectInput("sitePick",label = strong("Select Site:"),
                                                   edisDesc$Prj_ID,selected = edisDesc$Prj_ID[1]))),
                       fluidRow(column(6,
                                       strong(textOutput("text1")))),
                       br(),
                       dygraphOutput("flowPlot",height="300px"),
                       br(),
                       br()
              ))),
            mainPanel(width = 6,leafletOutput("map",height='520px')),
          mainPanel(width=12,
            tabsetPanel(
              tabPanel("Site Descriptions",dataTableOutput("descTable")
                ),
              tabPanel("Time Series",dataTableOutput("edisTable")
                )
              ))
  ))