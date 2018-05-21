library(shiny)

library(DT)
library(leaflet)
library(ggplot2)
library(GeoLight)
library(lubridate)
library(scales)

#Bring in functions to make the main app work.
#These are the pager for the editting plot 
#and the adapted twilight calculation function from GeoLight.
source("global.R")

#Define UI for application
#This is where you lay out page design and specify buttons, etc.
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
                   h3("Step 1b. Calibration period information"),
                   numericInput("calib_lon", 
                                h4("Calibration longitude"), 
                                value = 0,
                                step = 0.00001),
                   numericInput("calib_lat", 
                                h4("Calibration latitude"), 
                                value = 0,
                                step = 0.00001),
                   dateInput("start_calib_date", 
                             h4("Calibration start date"), 
                             value = NULL),
                   dateInput("stop_calib_date", 
                             h4("Calibration stop date"), 
                             value = NULL),
                   numericInput("sunangle", "Sun angle", value = 0),
                   actionButton("calculate", "Calculate sun angle from data"),
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


#This actionButton is linked by its name to an observeEvent in the server function
#When you press this the mymap object is shown.
actionButton("update_map", "Update map"),

leafletOutput("mymap"),
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
  
  #Make the size of file that you can upload larger than default.
  options(shiny.maxRequestSize=30*1024^2) 

  #List out results that you entered at start of sidebar.
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
  
  #Read in a dataset from a file.
  geolocatordata <- reactive({
    
    #req() ensures that if file hasn't been read in yet,
    #the rest of the code doesn't crash with errors.
    #https://shiny.rstudio.com/articles/req.html
    req(input$filename)
    inFile <- input$filename
    if (is.null(inFile))
      return(NULL)
    
    tbl <- read.csv(inFile$datapath,
                    header = FALSE,
                    sep=",")
    #specifies date and time format.
    #will need adapting to other files not like my test .lig file.
    tbl$datetime <- as.POSIXct(strptime(tbl$V2,
                                        format = "%d/%m/%y %H:%M:%S",
                                        tz = "GMT"))
    tbl$lightlevel <- tbl$V4
    return(tbl)
  })
  
  #create a user interface dynamic slider based on reactive data
  output$dateslider <- renderUI({
    sliderInput("dateslider",
                "datetime",
                min = min(geolocatordata()$datetime),
                max = max(geolocatordata()$datetime),
                value = c(min(geolocatordata()$datetime),
                          min(geolocatordata()$datetime)+days(2), #This sets the initial range to first two days of the dataset
                          width = '100%'))
  })
  
  #Create reactive object that calculates twilights.
  probTwilights <- reactive ({
  twl <- TAGS_twilight_calc(geolocatordata()$datetime, 
                            geolocatordata()$light, 
                            LightThreshold = input$light_threshold)
  
  consecTwilights <- twl[[2]]
  consecTwilights$timetonext <- difftime(time1 = consecTwilights$tSecond,
                                         time2 = consecTwilights$tFirst,
                                         units = "hours")
  #flag twilights with < 5 hrs time to next twilight as potential problems.
  probTwilights <- consecTwilights[consecTwilights$timetonext < 5,]
})
  
  #use renderPlot function to pass to output "plotall" 
  #which is placed up in layout.
  output$plotall <- renderPlot({

    ggplot() + 
      geom_line(data = geolocatordata(), 
                mapping = aes(geolocatordata()$datetime,
                    geolocatordata()$lightlevel))+
      #draw a line showing where you have set light threshold
      geom_hline(yintercept = input$light_threshold,
                 col = "orange")+
      #draw red boxes around problem twilights
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
  #with modifications from 
  #https://groups.google.com/forum/#!topic/shiny-discuss/YyupMW66HZ8 
  #to adapt to file upload
  
  vals <- reactiveValues( 
    keeprows = NULL
    )
  
  observe({
    vals$keeprows <- rep(TRUE,
                         nrow(geolocatordata()))
  })
  
  #########################
  #Paging implementation from 
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
  
  #Plot only the paged/selected rows.
  output$plotselected <- renderPlot({

    #First generate true/false list of which rows are plotted via pages().
    rows <- pages()[[input$pager$page_current]]
    
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
      coord_cartesian(xlim = c(min(geolocatordata()[rows,"datetime"]),
                               max(geolocatordata()[rows,"datetime"])),
                      ylim = c(min(geolocatordata()[,"lightlevel"]),
                               max(geolocatordata()[,"lightlevel"])))+
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
  
  # Toggle points that are selected, when toggle button is clicked
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
  #A table to show what values you have excluded
  #Removing it speeds up running.
  
  output$excludedtbl <- renderDT(geolocatordata()[!vals$keeprows, , drop = FALSE],
                                 server = TRUE)
  
  ##################
  #Adding true/false keep column to new reactive data frame
  #This column needs to be in the final downloaded dataset.
  ##################
  geolocatordata_keep <- reactive ({
    df <- geolocatordata()
    df$keeprows <- vals$keeprows
    return(df)
  })
  
  ##################
  #Calibration/computation of sun elevation angle from calibration data.
  ##################
  
  #Create a reactive object that is updated
  #when keep values are altered by clicks.
  #It is updated and then the calibration object (calib)
  #is updated too with new values generated by edited_twilights.
  edited_twilights <- reactive ({
    edited_twilights <- twilightCalc(geolocatordata_keep()$datetime,
                                     geolocatordata_keep()$lightlevel,
                                     ask=F)
  })
  
  calib <- reactive ({

      calib <- subset(edited_twilights(),
                      (as.numeric(as.Date(edited_twilights()$tSecond)) < as.numeric(input$stop_calib_date))&
                        (as.numeric(as.Date(edited_twilights()$tFirst)) > as.numeric(input$start_calib_date))  
    
    )
    
    
  })

  #observeEvent says when you click on "calculate" it gives you a new 
  #value for sun angle and updates the number input's manually entered entry.
   observeEvent(input$calculate, {
    elev <- getElevation(calib()$tFirst,
                 calib()$tSecond, 
                 calib()$type,
                 known.coord=c(input$calib_lon,
                               input$calib_lat) )
    updateNumericInput(session,
                       "sunangle", 
                       value = as.numeric(elev))
  })
  


  ##################
  #MAP
  ##################

   #On clicking the actionButton update_map,
   #the map is generated or refreshed with new values.
   #having this isolated in observeEvent keeps it from updating
   #constantly and using more server time.
   observeEvent(input$update_map, {
     output$mymap <- renderLeaflet({
       
       #Get coordinates for all consecutive twilights.
       coord <- coord(edited_twilights()$tFirst,
                      edited_twilights()$tSecond,
                      edited_twilights()$type,
                      degElevation=input$sunangle)
       
       #run the leaflet function
       leaflet() %>%
         #add map tiles
         addProviderTiles(providers$Stamen.TonerLite,
                          options = providerTileOptions(noWrap = TRUE)
         ) %>%
         #add the calculated coordinates based on edited twilights
         addMarkers(data = coord)
     })
   })
   

   


  
  ##################
  #Code to do downloading here and in UI adapted from here:
  #https://stackoverflow.com/questions/41856577/upload-data-change-data-frame-and-download-result-using-shiny-package
  ##################
  
  output$downloadData <- downloadHandler(
    
    filename = function() { 
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    
    content = function(file) {
      
      write.csv(geolocatordata_keep(), file)
      
    })
}

#Run the application 
shinyApp(ui = ui, 
         server = server,
         options = list(display.mode = 'showcase'))

