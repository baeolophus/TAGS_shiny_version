#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(DT)
library(ggplot2)
library(GeoLight)
library(scales)

#geolocatordata <- read.csv("data/PABU222150719.lig",
#                   sep = ",",
#                   header = FALSE)

#geolocatordata$datetime <- as.POSIXct(strptime(geolocatordata$V2,
#                                     format = "%d/%m/%y %H:%M:%S",
#                                     tz = "GMT"))
#geolocatordata$lightlevel <- geolocatordata$V4

# Define UI for application
ui <- fluidPage(
  titlePanel(
             h1("Totally Awesome Geolocator Service")),
  
sidebarLayout(
      sidebarPanel(img(src = "TAGS_logo.png"),
                   br(),
                   h3("Step 1a. Select your file"),
                   fileInput("filename",
                             label = "Browse for your file"#,
                             #accept = c("text/csv",
                             #           "text/comma-separated-values,text/plain",
                            #            ".csv",
                            #            ".lig",
                             #           ".lux")
                            ),
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
                   h3("Step 1d. Upload your dataset")#,
                   #submitButton("Upload data")
                   ),
      mainPanel(
       h2("Step 1. Upload your data"),
       textOutput("selected_filetype"),
       textOutput("selected_species"),
       textOutput("selected_name"),
       textOutput("selected_notes"),
      h2("Step 2. Edit and analyze"),
      plotOutput("plotall",
                 height = "150px"),
#Input slider based on reactive dataframe.
#https://stackoverflow.com/questions/18700589/interactive-reactive-change-of-min-max-values-of-sliderinput
      uiOutput("dateslider"),

      plotOutput("plotselected",
                 click = "plotselected_click",
                 brush = brushOpts(
                   id = "plotselected_brush"
                 )
      ),
      actionButton("exclude_toggle", "Toggle points"),
      actionButton("exclude_reset", "Reset"),
      br(),
      DTOutput('excludedtbl'),
        img(src = "step2.png"),
        h2("Step 3. View and download results"),
        img(src = "step3.png")
      )

))

# Define server logic required
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
  
  geolocatordata <- reactive({
    
    #https://shiny.rstudio.com/articles/req.html
    req(input$filename)
    inFile <- input$filename
    if (is.null(inFile))
      return(NULL)
    
    tbl <- read.csv(inFile$datapath,
                    header = FALSE,
                    sep=",")
    tbl$datetime <- as.POSIXct(strptime(tbl$V2,
                                        format = "%d/%m/%y %H:%M:%S",
                                        tz = "GMT"))
    tbl$lightlevel <- tbl$V4
    return(tbl)
  })
  #dynamic slider based on reactive data
  output$dateslider <- renderUI({
    sliderInput("dateslider",
                "datetime",
                min = min(geolocatordata()$datetime),
                max = max(geolocatordata()$datetime),
                value = c(min(geolocatordata()$datetime),
                          max(geolocatordata()$datetime),
                          width = '100%'))
  })
  

  output$plotall <- renderPlot({
    
    ggplot(geolocatordata(), 
           aes(geolocatordata()$datetime,
               geolocatordata()$lightlevel)) + 
      geom_line() 
  })
  
  #Store excluded rows
  #with modifications from https://groups.google.com/forum/#!topic/shiny-discuss/YyupMW66HZ8 to adapt to file upload
  vals <- reactiveValues( 
    keeprows = NULL
    )
  
  observe({
    vals$keeprows <- rep(TRUE,
                         nrow(geolocatordata()))
  })
  

  output$plotselected <- renderPlot({
    # Plot the kept and excluded points as two separate data sets
    keep    <- geolocatordata()[ vals$keeprows, , drop = FALSE]
    exclude <- geolocatordata()[!vals$keeprows, , drop = FALSE]
    
    ggplot(keep, 
           aes(datetime,
               lightlevel)) + 
      geom_point()+
      geom_line()+
      geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25)+
      scale_x_datetime(limits = c(input$dateslider[1],
                                  input$dateslider[2]))
  })
  
  # Toggle points that are clicked
  observeEvent(input$plotselected_click, {
    res <- nearPoints(geolocatordata(),
                      input$plotselected_click,
                      allRows = TRUE)
    
    vals$keeprows <- xor(vals$keeprows, res$selected_)
  })
  
  # Toggle points that are brushed, when button is clicked
  observeEvent(input$exclude_toggle, {
    res <- brushedPoints(geolocatordata(),
                         input$plotselected_brush,
                         allRows = TRUE)
    
    vals$keeprows <- xor(vals$keeprows, res$selected_)
  })
  output$excludedtbl <- renderDT(geolocatordata()[!vals$keeprows, , drop = FALSE],
                                 server = TRUE)
}

# Run the application 
shinyApp(ui = ui, 
         server = server,
         options = list(display.mode = 'showcase'))

