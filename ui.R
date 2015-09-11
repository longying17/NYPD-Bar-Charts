library(shiny)

shinyUI(fluidPage(
  titlePanel("NYPD Bar Charts"),
  fluidRow(
    column(4, tabsetPanel(
      tabPanel("Axes", wellPanel(
      selectInput("Yaxis", "Y-axis Variable", choices = QuanOptions),
      conditionalPanel(condition = "input.Yaxis == 'Force'",
                       selectizeInput("ModifyForce", 
                                      "Select the Type of Force",
                                      choices = ForceVariables,
                                      selected = ForceVariables,
                                      multiple = TRUE)),
      selectInput("Xaxis", "X-axis Variable", choices = CatOptions),
      radioButtons("YType", label = "Y-axis Measurement", inline = TRUE,
                   choices = c("Counts" = "Counts", 
                               "Percentage Of Stops" = "Percentage",
                               "Percentage of Arrests" = "ArrestPercent"),
                   selected = "Counts"),
      sliderInput("Year", "Choose the Years", 2006, 2014, 
                  value = c(2006, 2014), sep = "", animate = TRUE),
      
      selectInput("Facet", "Facet By", choices = c("None", CatOptions)),
      conditionalPanel(condition = "input.Yaxis != 'Force'",
                       selectInput("Color", "Color By", 
                                   choices = c("None", CatOptions)))
      )),
      
      tabPanel("Filters", wellPanel(
        selectizeInput("ModifyRace",
                       "Filter by Race",
                       choices = RaceVariables,
                       selected = RaceVariables,
                       multiple = TRUE),
        selectizeInput("ModifyGender",
                       "Filter by Gender",
                       choices = GenderVariables,
                       selected = GenderVariables,
                       multiple = TRUE),
        selectizeInput("ModifyCrime",
                       "Filter by Crime Type",
                       choices = CrimeVariables,
                       selected = CrimeVariables,
                       multiple = TRUE)
        ))
    )),
    
    column(8, plotOutput("BarChart", height = "500px"))
    
    )))