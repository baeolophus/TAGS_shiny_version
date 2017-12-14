#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

#Sample_lig_data <- read.csv("shiny_test/data/PABU222150719.lig",
#                            header = FALSE)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel(
             h1("Totally Awesome Geolocator Service")),
  
sidebarLayout(
      sidebarPanel(img(src = "TAGS_logo.png"),
                   br(),
                   h3("Step 1a. Select your file"),
                   fileInput("filename",
                             label = "Browse for your file"),
                   radioButtons("filetype", 
                                label = "Select your filetype",
                                choices = list(".lux", 
                                               ".lig",
                                               "generic text"),
                                selected = "generic text"),
                   textInput("name",
                             h4("Name"),
                             placeholder = "PABU_123"),  #name
                   textInput("species",
                             h4("Species"),
                             placeholder = "Painted Bunting"), #species
                   textInput("notes",
                             h4("Notes"),
                             value = "Any notes here."),#notes
                   br(),
                   h3("Step 1b. Specify your release location and date"),
                   numericInput("release_lat", 
                                h4("Release latitude"), 
                                value = 0,
                                step = 0.00001),
                   numericInput("release_lon", 
                                h4("Release longitude"), 
                                value = 0,
                                step = 0.00001),
                   dateInput("release_date", 
                             h4("Release date"), 
                             value = NULL),
                   br(),
                   h3("Step 1c. Specify your recapture location and date"),
                   br(),
                   numericInput("recap_lat", 
                                h4("Recapture latitude"), 
                                value = 0,
                                step = 0.00001),
                   numericInput("recap_lon", 
                                h4("Recapture longitude"), 
                                value = 0,
                                step = 0.00001),
                   dateInput("recap_date", 
                             h4("Recapture date"), 
                             value = NULL),
                   br(),
                   h3("Step 1d. Upload your dataset"),
                   submitButton("Upload data")
                   ),
      mainPanel(
       h2("Step 1. Upload your data"),
       textOutput("selected_filetype"),
       textOutput("selected_species"),
       textOutput("selected_name"),
       textOutput("selected_notes"),
      h2("Step 2. Edit and analyze"),
        img(src = "step2.png"),
        h2("Step 3. View and download results"),
        img(src = "step3.png")
      )

))

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$selected_filetype <- renderText({ 
    paste0("Your filetype is ", input$filetype)
  })
  output$selected_species <- renderText({ 
    paste0("Your species is ", input$species)
  })
  output$selected_name <- renderText({ 
    paste0("Your name is ", input$name)
  })
  output$selected_notes <- renderText({ 
    paste0("Your notes say '",
          input$notes,
          "'")
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

