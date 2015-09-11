library(dplyr)
library(readr)
library(shiny)

####### Read in the sumNYPD dataset #######
sumNYPD <- read_csv("sumNYPD.csv")

####### Read in the arrestNYPD dataset #######
arrestNYPD <- read_csv("arrestNYPD.csv")

####### Custom Colors #######
customColors <- c("#a6cee3", "#1f78b4", "#b2df84", "#33a02c",
                  "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00")

####### Force Variables #######
ForceVariables <- c("Hands" = "Hands",
                    "Wall" = "Wall",
                    "Ground" = "Ground",
                    "HandCuff" = "HandCuff",
                    "Firearm" = "Firearm",
                    "Baton" = "Baton",
                    "PepperSpray" = "PepperSpray",
                    "Other" = "Other")

####### Race Variables #######
RaceVariables <- c("Asian" = "Asian",
                   "Black" = "Black",
                   "Hispanic" = "Hispanic",
                   "Native" = "Native",
                   "White" = "White",
                   "Other" = "Other")

####### Gender Variables #######
GenderVariables <- c("Female" = "Female",
                     "Male" = "Male",
                     "Unknown" = "Unknown")

####### Crime Type Variables #######
CrimeVariables <- c("Assault" = "Assault",
                    "Contraband" = "Contraband",
                    "Felony" = "Felony",
                    "Larceny" = "Larceny",
                    "Misdemeanor" = "Misdemeanor",
                    "Other" = "Other")

####### Categorical Variables #######
CatOptions = c("Race" = "Race",
               "Gender" = "Gender",
               "Crime Type" = "CrimeType",
               "Year" = "Year")

####### Quantitative Variables #######
QuanOptions = c("Stopped" = "Stopped",
                "Frisked" = "Frisked",
                "Searched" = "Searched",
                "Arrested" = "Arrested",
                "Force" = "Force",
                ForceVariables)

