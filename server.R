library(shiny)
library(ggplot2)
library(reshape2)
library(plyr)
library(dplyr)
library(scales)

shinyServer(function(input, output){

  FilterNYPD <- function(dataset){
    dataset <- dataset[dataset$Year >= input$Year[1] &
                         dataset$Year <= input$Year[2], ]
    
    dataset <- dataset[dataset$Race %in% input$ModifyRace &
                         dataset$Gender %in% input$ModifyGender &
                         dataset$CrimeType %in% input$ModifyCrime, ]
    
    dataset
  }
  
  ModifyForce <- reactive({
    if(input$YType == "Counts"){
      sumNYPD <- FilterNYPD(sumNYPD)
      
      meltNYPD <- melt(sumNYPD, id.vars = c("pct", CatOptions),
                       measure.vars = input$ModifyForce)

      currentData <- data.frame("Year" = meltNYPD$Year,
                                "Xvar" = meltNYPD[[input$Xaxis]],
                                "variable" = meltNYPD$variable,
                                "value" = meltNYPD$value)

      if(input$Facet != "None"){
        currentData$Facet <- meltNYPD[[input$Facet]]
      }
    } else{
      if(input$YType == "ArrestPercent"){
        sumNYPD <- arrestNYPD
      }
      sumNYPD <- FilterNYPD(sumNYPD)
      
      currentData <- data.frame("Year" = sumNYPD$Year,
                                "Xvar" = sumNYPD[[input$Xaxis]],
                                "Hands" = sumNYPD$Hands,
                                "Wall" = sumNYPD$Wall,
                                "Ground" = sumNYPD$Ground,
                                "HandCuff" = sumNYPD$HandCuff,
                                "Firearm" = sumNYPD$Firearm,
                                "Baton" = sumNYPD$Baton,
                                "PepperSpray" = sumNYPD$PepperSpray,
                                "Other" = sumNYPD$Other)
      
      if(input$YType == "ArrestPercent"){
        currentData <- mutate(currentData, DivideBy = sumNYPD$Arrested)
      } else if(input$YType == "Percentage"){
        currentData <- mutate(currentData, DivideBy = sumNYPD$Stopped)
      }

      ddplyVariables <- c("Xvar")

      if(input$Facet != "None"){
        currentData$Facet <- sumNYPD[[input$Facet]]
        ddplyVariables <- c(ddplyVariables, "Facet")
      }

      currentData <- ddply(currentData, ddplyVariables, summarise,
                          DivideBy = sum(DivideBy),
                          Hands = sum(Hands) / sum(DivideBy),
                          Wall = sum(Wall) / sum(DivideBy),
                          Ground = sum(Ground) / sum(DivideBy),
                          HandCuff = sum(HandCuff) / sum(DivideBy),
                          Firearm = sum(Firearm) / sum(DivideBy),
                          Baton = sum(Baton) / sum(DivideBy),
                          PepperSpray = sum(PepperSpray) / sum(DivideBy),
                          Other = sum(Other) / sum(DivideBy))

      currentData <- melt(currentData, id.vars = ddplyVariables,
                         measure.vars = input$ModifyForce)
    }

    currentData
  })

  prepareCountsData <- reactive({
    sumNYPD <- FilterNYPD(sumNYPD)
    
    if(input$Color != "None"){
      sumNYPD <- arrange(sumNYPD, sumNYPD[[input$Color]])
    }

    if(!is.null(input$ModifyForce) & input$Yaxis == "Force"){
      currentData <- ModifyForce()
    } else{
      currentData <- data.frame("Year" = sumNYPD$Year,
                                "Xvar" = sumNYPD[[input$Xaxis]],
                                "Yvar" = sumNYPD[[input$Yaxis]])

      if(input$Facet != "None"){
        currentData$Facet <- sumNYPD[[input$Facet]]
      }

      if(input$Color != "None"){
        currentData$Color <- sumNYPD[[input$Color]]
      }
    }

    currentData
  })

  preparePercentData <- reactive({
    if(input$YType == "ArrestPercent"){
      sumNYPD <- arrestNYPD
    }
    
    sumNYPD <- FilterNYPD(sumNYPD)
    
    if(!is.null(input$ModifyForce) & input$Yaxis == "Force"){
      currentData <- ModifyForce()
    } else{
      currentData <- data.frame("Year" = sumNYPD$Year,
                                "Xvar" = sumNYPD[[input$Xaxis]],
                                "Yvar" = sumNYPD[[input$Yaxis]])
      
      if(input$YType == "ArrestPercent"){
        currentData <- mutate(currentData, DivideBy = sumNYPD$Arrested)
      } else if(input$YType == "Percentage"){
        currentData <- mutate(currentData, DivideBy = sumNYPD$Stopped)
      }

      ddplyVariables <- c("Xvar")

      if(input$Facet != "None"){
        currentData$Facet <- sumNYPD[[input$Facet]]
        ddplyVariables <- c(ddplyVariables, "Facet")
      }

      if(input$Color != "None"){
        currentData$Color <- sumNYPD[[input$Color]]
        ddplyVariables <- c(ddplyVariables, "Color")
      }

      currentData <- ddply(currentData, ddplyVariables, summarise,
                          totalYvar = sum(Yvar), DivideBy = sum(DivideBy))

      currentData$Percentage <- currentData$totalYvar / currentData$DivideBy
    }

    currentData
  })

  output$BarChart <- renderPlot({
    validate(
      if(is.null(input$ModifyForce)){
        "Please select a type of force"
      },
      if(is.null(input$ModifyRace)){
        "Please select at least one race"
      },
      if(is.null(input$ModifyGender)){
        "Please select at least one gender"
      },
      if(is.null(input$ModifyCrime)){
        "Please select at least one crime type"
      }
      )
    
    if(input$YType == "Counts"){
      currentData <- prepareCountsData()
    } else{
      currentData <- preparePercentData()
    }

    if(!is.null(input$ModifyForce) & input$Yaxis == "Force"){
      currentPlot <- ggplot(
        data = currentData,
        aes(x = Xvar, y = value, fill = variable)) +
        geom_bar(position="stack", stat="identity") +
        scale_colour_manual(values=customColors) +
        xlab("Force")
    } else{
      if(input$YType == "Counts"){
        currentPlot <- ggplot(
          data=currentData,
          aes(x = Xvar, y = Yvar))
      } else {
        currentPlot <- ggplot(
          data=currentData,
          aes(x = Xvar, y = Percentage))
      }
      
      currentPlot <- currentPlot + 
        geom_bar(stat = "identity", position="stack") +
        xlab(input$Xaxis) + scale_y_continuous(labels = comma)

      # Color:
      if(input$Color != "None"){
        currentPlot <- currentPlot + aes(fill=Color) +
        theme(legend.position="right", axis.title=element_text(size=18)) +
        scale_colour_manual(values=customColors)
      }
    }
    
    currentPlot <- currentPlot + 
      theme(axis.title=element_text(size=18))
    
    if(input$Xaxis == "Year"){
      currentPlot <- currentPlot + scale_x_continuous(breaks = 2006:2014)
    }
    
    if(input$YType == "Counts"){
      currentPlot <- currentPlot + ylab("Counts")
    } else if(input$YType == "Percentage"){
      currentPlot <- currentPlot + ylab("Percentage of Stops")
    } else if(input$YType == "ArrestPercent"){
      currentPlot <- currentPlot + ylab("Percentage of Arrests")
    }

    if(input$YType == "Percentage" | input$YType == "ArrestPercent"){
      currentPlot <- currentPlot +
        scale_y_continuous(labels = percent_format())
    }

    # Facets:
    if(input$Facet != "None"){
      currentPlot <- currentPlot + facet_wrap(~Facet, ncol=3) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }

    currentPlot
  })
})
