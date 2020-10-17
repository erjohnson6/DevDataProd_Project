#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(data.table)
library(dplyr)
library(ggplot2)
library(lubridate)

webpathConf <- "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
StartDate <- "2020-03-01"
fileName <- "time_series_covid19_confirmed_US.csv"


# Define server logic required to draw the line graph
shinyServer(function(session, input, output) {
    webpathConf <- "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    StartDate <- "2020-03-01"
    fileName <- "time_series_covid19_confirmed_US.csv"
    
    if(!file.exists(fileName)) {
        download.file(webpathConf, destfile = fileName, mode='wb')
    }
    USConfWide <- as.data.table(read.csv(fileName))
    USConfNarrow <- melt(USConfWide, id.vars = 1:11, value.name = "Confirmed", variable.name = "Date")
    USConfNarrow$Confirmed <- replace(USConfNarrow$Confirmed, USConfNarrow$Confirmed == 0, NA)
    USConfNarrow$Date <- mdy(gsub("X", "", USConfNarrow$Date))
    COVID.States <- filter(USConfNarrow, Date > StartDate)
    COVID.States <- group_by(as_tibble(COVID.States), Province_State, Date)
    COVID.States <- summarise(COVID.States, Confirmed = sum(Confirmed, na.rm = TRUE))
    lastDate <- max(COVID.States$Date)
    
    updateSelectizeInput(session, 'states',
                         choices = unique(COVID.States$Province_State),
                         selected = "Hawaii",
                         server = TRUE)

    makeTable <- reactive({
        t <- NULL
        t <- filter(COVID.States, Province_State %in% input$states & Date == lastDate)
        t$prevConf <- filter(COVID.States, Province_State %in% input$states & Date == (lastDate-10))[,3]
        t <- mutate(t, GrowthRate = 100*(exp((log(Confirmed/prevConf))/10)-1))
        select(t, Province_State, Confirmed, GrowthRate)
    })

    
    statePlot <- renderPlotly({
        plot_ly(COVID.States, x = ~Date, y = ~Confirmed, color = ~Province_State) %>%
            layout(yaxis = list(type = "log")) %>%
            filter(Province_State %in% input$states) %>%
            add_lines() 
    })
    
    output$stateCompare <- renderTable(makeTable())
    output$p <- statePlot

})
