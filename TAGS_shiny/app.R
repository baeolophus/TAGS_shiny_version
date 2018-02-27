library(shiny)

library(DT)
library(ggplot2)
library(GeoLight)
library(lubridate)
library(scales)

source("global.R")

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
                   h3("Step 1d. Upload your dataset"),
                   #submitButton("Upload data")
                   h3("Step 2. Light threshold entry"),
                   numericInput("light_threshold", 
                                h4("Light threshold"), 
                                value = 5.5,
                                step = 0.1)
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
########
#pager for zoomed data
numericInput('num_rows_per_page', 
             'Rows Per Page',
             value = 100,
             min = 1),
verbatimTextOutput('debug'),
pageruiInput('pager',
             page_current = 1),
########
      actionButton("exclude_toggle", "Toggle points"),
      actionButton("exclude_reset", "Reset"),
      br(),

downloadButton('downloadData', 'Download'),
br(),

br(),

      DTOutput('excludedtbl'),
        img(src = "step2.png"),
        h2("Step 3. View and download results"),
        img(src = "step3.png")
      )

))

server <- function(input, output, session) {
  options(shiny.maxRequestSize=30*1024^2) 

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
                          min(geolocatordata()$datetime)+days(2), #This sets the initial range to first two days of the dataset
                          width = '100%'))
  })
  
  probTwilights <- reactive ({
  twl <- TAGS_twilight_calc(geolocatordata()$datetime, 
                            geolocatordata()$light, 
                            LightThreshold = input$light_threshold)
  
  consecTwilights <- twl[[2]]
  consecTwilights$timetonext <- difftime(time1 = consecTwilights$tSecond,
                                         time2 = consecTwilights$tFirst,
                                         units = "hours")
  probTwilights <- consecTwilights[consecTwilights$timetonext < 5,]
})
  
  output$plotall <- renderPlot({



    ggplot() + 
      geom_line(data = geolocatordata(), 
                mapping = aes(geolocatordata()$datetime,
                    geolocatordata()$lightlevel))+
      geom_hline(yintercept = input$light_threshold,
                 col = "orange")+
      geom_rect(data = probTwilights(),
                mapping = aes(xmin = tFirst,
                    xmax = tSecond,
                    ymin = -Inf,
                    ymax = Inf),
                col = "red",
                fill = "red",
                alpha = 0.5)
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
  
  #########################
  #Paging implementation details from 
  #http://oddhypothesis.blogspot.com/2015/10/paging-widget-for-shiny-apps.html
  
  pages = reactive({
    nrow_data = nrow(geolocatordata())
    # rows_per_page = ceiling(nrow_data / input$pager$pages_total)
    
    row_starts = seq(1, nrow_data, by = input$num_rows_per_page)
    row_stops  = c(row_starts[-1] - 1, nrow_data)
    
    page_rows = mapply(`:`, row_starts, row_stops, SIMPLIFY=F)
    
    return(page_rows)
  })
  
  output$debug = renderPrint({
    str(input$pager)
  })

  observeEvent(
    eventExpr = {
      c(input$num_rows_per_page, input$sel_dataset)
    },
    handlerExpr = {
      
      pages_total = ceiling(nrow(geolocatordata()) / input$num_rows_per_page)
      
      page_current = input$pager$page_current
      if (input$pager$page_current > pages_total) {
        page_current = pages_total
      }
      
      updatePageruiInput(
        session, 'pager',
        page_current = page_current,
        pages_total = pages_total
      )
    }
  )
  
  ########################
  
  
  output$plotselected <- renderPlot({

    #First generate true/false list of which rows are plotted via pages().
    rows = pages()[[input$pager$page_current]]
    
    # Plot the kept and excluded points as two separate data sets
    keep    <- geolocatordata()[ vals$keeprows, , drop = FALSE] %>% .[rows,]
    exclude <- geolocatordata()[!vals$keeprows, , drop = FALSE] %>% .[rows,]

    ggplot() + 
      geom_point(data = keep, 
                 mapping = aes(datetime,
                     lightlevel))+
      geom_line(data = keep, 
                mapping = aes(datetime,
                              lightlevel))+
      geom_point(data = exclude,
                 mapping = aes(datetime,
                               lightlevel),
                 shape = 21, 
                 fill = NA, 
                 color = "black",
                 alpha = 0.25)+
      scale_x_datetime()+
      coord_cartesian(xlim = c(min(geolocatordata()[rows,"datetime"]), max(geolocatordata()[rows,"datetime"])),
                      ylim = c(min(geolocatordata()[,"lightlevel"]), max(geolocatordata()[,"lightlevel"])))+
      geom_hline(yintercept = input$light_threshold,
                 col = "orange")+
      geom_rect(data = probTwilights(),
                mapping = aes(xmin = tFirst,
                              xmax = tSecond,
                              ymin = -Inf,
                              ymax = Inf),
                col = "red",
                fill = "red",
                alpha = 0.5)
      
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
  

###################
#multiple rectangles
  #from https://stackoverflow.com/questions/46450531/can-users-interactively-draw-rectangles-on-an-image-in-r-via-shiny-app
  


  ###################
 # output$excludedtbl <- renderDT(geolocatordata()[!vals$keeprows, , drop = FALSE],
#                                 server = TRUE)
  
  ##################
  #Adding true/false keep column to new reactive data frame
  ##################
  geolocatordata_keep <- reactive ({
    df <- geolocatordata()
    df$keeprows <- vals$keeprows
    return(df)
  })
  
  ##################


  #download code here and in UI from
  #https://stackoverflow.com/questions/41856577/upload-data-change-data-frame-and-download-result-using-shiny-package
  output$downloadData <- downloadHandler(
    
    filename = function() { 
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    
    content = function(file) {
      
      write.csv(geolocatordata_keep(), file)
      
    })
}

# Run the application 
shinyApp(ui = ui, 
         server = server,
         options = list(display.mode = 'showcase'))

