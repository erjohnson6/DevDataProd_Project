#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("CoVID19 State Comparison"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            h2("Overview"),
            p("This application will allow you to select specific states and graph them 
               for comparison."),
            ## selectizeInput(),
            selectizeInput(
                inputId = "states", 
                label = "Select a state(s)", 
                choices = "stateList", 
                multiple = TRUE
            ),
            p("Once the states are selected we will be able to review the graph and
              a table comparing the latest confirmed cases and the average 10-day growth 
              rate. The growth rate is calculated as a percent daily growth."),
            p("GrowthRate (GR) is calculated using the following equation:"),
            p(withMathJax("$$\\ C_t = C_{t-10} * (1 + GR)^{10} $$"))
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput(outputId = "p"),
            h3("Selected States:"),
            tableOutput('stateCompare')
        )
    )
))
