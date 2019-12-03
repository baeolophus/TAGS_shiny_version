library(shiny)

#Required libraries other than shiny
library(dplyr)
library(DT)
library(FLightR)
library(GeoLight)
library(ggplot2)
library(leaflet)
library(lubridate)
library(scales)
library(shinycssloaders)

#######
#There are currently no analytics but you can find information on how to implement here:
# https://shiny.rstudio.com/articles/usage-metrics.html
# http://docs.rstudio.com/shinyapps.io/metrics.html#ApplicationMetrics

#To see how many github users have cloned the repository, visit here:
# https://github.com/baeolophus/TAGS_shiny_version/graphs/traffic

########
#Bring in functions to make the main app work.
#These are the pager for the editing plot 
#and the adapted twilight calculation function from GeoLight.
source("global.R")

########
#Define UI for application
#This is where you lay out page design and specify buttons, etc.
ui <- fluidPage(
  titlePanel(
             "Totally Awesome Geolocator Service",
             windowTitle = "TAGS"),
  # img(src = "images/TAGS_logo.png"),
  # #TAGS logo placed here
sidebarLayout(
      sidebarPanel(
                   
                   h3("Step 1. Select your file"),
                   p("File upload limit of 30 mb; please run the app on your own machine if you have larger datasets."),
                   tags$a(href="https://github.com/baeolophus/TAGS_shiny_version",
                          "Get the TAGS app code here."),
                   br(),
                   tags$a(href="mailto: cmcurry@ou.edu",
                          "Contact Claire M. Curry with any questions."),
                   br(),
                   radioButtons("filetype", 
                                label = "Select your filetype before browsing for your file",
                                choices = list(".csv (generic data)",
                                               ".lig",
                                               ".lux"
                                ),
                                selected = ".csv (generic data)"),
                   
                   fileInput("filename",
                             label = "Browse for your file",
                             accept = c("text/csv",
                                        "text/comma-separated-values,text/plain",
                                        ".csv",
                                        ".lig",
                                        ".lux")
                            ),
                   br(), #linebreak
                   h3("Step 2. Calibration period information"),
                   numericInput("calib_lon", 
                                h4("Calibration longitude"), 
                                value = 0, #default value
                                step = 0.00001), #"steps" with arrow buttons.
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
                   #Enter a value for sun angle. 
                   #Or, this is also where calculated value appears if you press actionButton "calculate"
                   numericInput("sunangle", "Sun angle", value = 0),
                   actionButton("calculate", "Calculate sun angle from data"),
                   br(),
                   h3("Step 3. Light threshold entry"),
                   #Enter a value for light threshold to calculate sunrise/sunset.
                   numericInput("light_threshold", 
                                h4("Light threshold"), 
                                value = 5.5,
                                step = 0.1),
                   br(),
                   h3("Step 4. Optional: change value for finding problem areas"),
                   #Enter a value for length of time between twilights to count as a potential problem.
                   p("This is the difference in twilight times in hours that will highlight a twilight as a potential problem in red."),
                   p("Five hours is usually suitable, but you can experiment if you wish to highlight further potential problems."),
                   p("Changing the value will not erase your previous selections for excluded points."),
                   
                   numericInput("problem_threshold", 
                                h4("Problem threshold (hours)"), 
                                value = 5,
                                step = 1,
                                min = 0,
                                max = 24)
                   

),
      mainPanel(

      h2("Step 5. Find problem areas and edit your data"),
      p("This plot shows all of your data with problem areas highlighted in red boxes and the location of the editing window shown in gray."),
      p("An error may show briefly but the plot is still loading as long as the loading indicator returns."),
      #This places a plot in main area that shows all values from 
      #output$plotall (generated in server section)
      withSpinner(plotOutput("plotall",
                 height = "150px")),
     
      
##############################
#Input slider based on reactive dataframe.
#https://stackoverflow.com/questions/18700589/interactive-reactive-change-of-min-max-values-of-sliderinput

uiOutput("dateslider"),

p("The plot below can be edited by clicking a single data point or left-clicking and dragging your cursor to select multiple points."),

radioButtons("edit_units", 
             label = "Select your time units",
             choices = list("days",
                            "hours"),
             selected = "days"),


numericInput("time_window", "Editing window length",
             value = 2), #Default shows 2 days in seconds (172800) for posixct

numericInput("overlap_window", "What overlap with previous window?",
             value = round(1/24, 2)), #Default shows 1 hour in seconds (3600 sec)
p("Use the Previous and Next buttons to move to the next or previous editing window or problem twilight"),
actionButton("click_Prev", "Previous editing window"),
actionButton("click_Next", "Next editing window"),
br(),
actionButton("click_PrevProb", "Previous problem"),
actionButton("click_NextProb", "Next problem"),
##############################
#plot a subset of the data that is zoomed in enough to see and edit individual points.
      plotOutput("plotselected",
                 click = "plotselected_click",
                 brush = brushOpts(
                   id = "plotselected_brush"
                 )
      ),
#buttons to toggle editing plot points selected by a box.
actionButton("exclude_toggle", "Toggle currently selected points"),
actionButton("exclude_reset", "Reset ALL EXCLUDED POINTS"),
br(),

actionButton("render_edits", "Show/refresh edited values"),
DTOutput('excludedtbl'),
h2("Step 6. Generate coordinates"),

#This actionButton is linked by its name (update_map) to an observeEvent in the server function
#When you press this the keep dataset is generated and the mymap object is shown.

actionButton("create_data", "6A. Generate edited twilights for coordinate calculation"),
DTOutput('data_preview'),

br(),
actionButton("update_map", "6B. Generate map from edited twilights"),
#Map showing calculated coordinates from sunrise/sunset times.
leafletOutput("mymap"),
br(),

h2("Step 7. Download data"),

#Button to download data.
downloadButton('downloadData', 'Download TAGS format (original data with edits and twilights)'),

#Add one for coordinates only
downloadButton('downloadDataCoord', 'Download edited coordinates only'),

#Add one for edited twilights only
downloadButton('downloadDataTwilights', 'Download edited twilights only')




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

  #########################
  #Read in a dataset from a file.
  geolocatordata <- reactive({
    
    #req() ensures that if file hasn't been read in yet,
    #the rest of the code doesn't crash with errors.
    #https://shiny.rstudio.com/articles/req.html
    req(input$filename)
    inFile <- input$filename
    
    #Nesting ifelse shows what to do if inFile is null (no entry)
    #and what to do for each input radio button type.
    if (is.null(inFile)) {return(NULL)} else
    {
      if (input$filetype == ".lig") {
        
        tbl <- read.csv(inFile$datapath,
                        header = FALSE,
                        sep=",")
        #specifies date and time format.
        tbl$datetime <- as.POSIXct(strptime(tbl$V2,
                                            format = "%d/%m/%y %H:%M:%S",
                                            tz = "GMT"))
        tbl$light <- tbl$V4
        tbl <- tbl[, c("datetime",
                       "light")]
        return(tbl)
        
      } else 
        {
          if (input$filetype == ".lux") {
        
        tbl <- read.csv(inFile$datapath,
                        header = FALSE,
                        sep="\t", #.lux is tab separated not comma
                        skip = 20)
        
        #names headers
        names(tbl) <- c("datetime", "light")
        #specifies date and time format.
        tbl$datetime <- as.POSIXct(strptime(tbl$datetime,
                                            format = "%d/%m/%Y %H:%M:%S",
                                            tz = "GMT"))
        return(tbl)
        
      } else {
        #all else should be .csv files.
        tbl <- read.csv(inFile$datapath,
                        header = TRUE,
                        sep=",")
        #renames headers if incorrect
        names(tbl) <- c("datetime", "light")
        #specifies date and time format.
        tbl$datetime <- as.POSIXct(strptime(tbl$datetime,
                                            format = "%Y-%m-%d %H:%M:%S",
                                            tz = "GMT"))
        #Should add error notifications here for if something goes wrong in conversions.
        #use showNotification()
        return(tbl)
        }
      }
    }
  }) 
      
  #########################
  #Create reactive object to put a value into seconds from the edit_units,
  #input$time_window, and input$overlap_window, because posixct seconds are actually required to make it work.

  time_window <- reactive ({
    if (input$edit_units == "days")
    {window_size_in_sec <- input$time_window * 24 * 60 * 60
  return(window_size_in_sec)}
  else
  {{window_size_in_sec <- input$time_window * 60 * 60
  return(window_size_in_sec)}}   
  })  
  
  overlap_window <- reactive ({
    if (input$edit_units == "days")
    {overlap_size_in_sec <- input$overlap_window * 24 * 60 * 60
    return(overlap_size_in_sec)}
    else
    {{overlap_size_in_sec <- input$overlap_window * 60 * 60
    return(overlap_size_in_sec)}}   
  })      
  
#########################
  #create a user interface dynamic slider based on reactive data
  #shows where the start of the editing window is located and changed with that change in value.
  output$dateslider <- renderUI({
    sliderInput("dateslider",
                "Start date/time of editing window",
                min = min(geolocatordata()$datetime, na.rm = TRUE),
                max = max(geolocatordata()$datetime, na.rm = TRUE),
                value = min(geolocatordata()$datetime, na.rm = TRUE), #This sets the initial range to first two days of the dataset
                          width = '100%')
  })
  
#########################
  #Set the value of the left side of the editing window as a reactive that can change
  #with the value of the date slider.  This also allows you to change the window
  #location with the next/prev buttons.
  window_x_min <- reactiveValues()
  window_x_min$x <- NULL
  
  observe({
    window_x_min$x <- input$dateslider #starts at the value of the date slider which starts at the minimum x value of dataset.
  })
  #########################
  #Create reactive object that calculates problem twilights.
  #THIS SECTION IS WHERE YOU WOULD PUT NEW METHODS FOR CALCULATING PROBLEM REGIONS.
  #this is a method for calculating problems that uses
  #GeoLight's twilight finder modified to remove some options.
  twl <- reactive({
    TAGS_twilight_calc(geolocatordata()$datetime, 
                            geolocatordata()$light, 
                            LightThreshold = input$light_threshold,
                       allTwilights = TRUE)
  })
  
  probTwilights <- reactive ({
  
  consecTwilights <- twl()[[2]]
  consecTwilights$timetonext <- difftime(time1 = consecTwilights$tSecond,
                                         time2 = consecTwilights$tFirst,
                                         units = "hours")
  #Then we flag twilights with < 5 hrs time to next twilight as potential problems.
  probTwilights <- consecTwilights[consecTwilights$timetonext < input$problem_threshold,
                                   c("tFirst",
                                     "tSecond",
                                     "type")]
  #This final object is the one that is passed outside as the reactive object used later.
  #So if you do additional methods or change it, make sure the last object is the one that contains
  #problem twilights with columns tFirst (POSIXct), tSecond (POSIXct), and type (num)
})
  
  #########################  
  #use renderPlot function to pass to output "plotall" 
  #which is placed up in layout.  This shows the whole dataset and all problem regions.
  output$plotall <- renderPlot({
    ggplot() + 
      geom_line(data = geolocatordata(), 
                mapping = aes(geolocatordata()$datetime,
                    geolocatordata()$light))+
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
                alpha = 0.5)+
      labs(x = "datetime", 
           y = "light")+
      #draw pale gray box over editing window
      annotate("rect",
               xmin = window_x_min$x,
               xmax = window_x_min$x+time_window(),
               ymin = -Inf,
               ymax = Inf,
               col = "gray",
               fill = "gray",
               alpha = 0.5)
  })
  
  

  
  #Store excluded rows
  #with modifications from 
  #https://groups.google.com/forum/#!topic/shiny-discuss/YyupMW66HZ8 
  #to adapt to file upload
  
  vals <- reactiveValues( 
    excluded = NULL
    )
  
  observe({
    vals$excluded <- rep(FALSE,
                         nrow(geolocatordata()))
  })

  ########################
  
  #Plot only the paged/selected rows.
  output$plotselected <- renderPlot({

    
    # Plot the kept and excluded points as two separate data sets
    keep    <- geolocatordata()[ vals$excluded == FALSE, , drop = FALSE]
    exclude <- geolocatordata()[ vals$excluded == TRUE, , drop = FALSE]

    ggplot() + 
      geom_point(data = keep, 
                 mapping = aes(datetime,
                     light))+
      geom_line(data = keep, 
                mapping = aes(datetime,
                              light))+
      geom_point(data = exclude,
                 mapping = aes(datetime,
                               light),
                 shape = 21, 
                 fill = NA, 
                 color = "black",
                 alpha = 0.25)+
      scale_x_datetime()+
      coord_cartesian(xlim = c(input$dateslider,
                               input$dateslider+time_window()),
                      ylim = c(min(geolocatordata()[,"light"], na.rm = TRUE),
                               max(geolocatordata()[,"light"], na.rm = TRUE)))+
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
    
    vals$excluded <- xor(vals$excluded, res$selected_)
  })
  
  # Toggle points that are selected, when toggle button is clicked
  observeEvent(input$exclude_toggle, {
    res <- brushedPoints(geolocatordata(),
                         input$plotselected_brush,
                         allRows = TRUE)
    
    vals$excluded <- xor(vals$excluded, res$selected_)
  })
  observeEvent(input$exclude_reset, 
               {
                 vals$excluded <- rep(FALSE,
                                      nrow(geolocatordata()))
                 }
               )
  
##################
  #Buttons for moving forward and backwards in the dataset
  
  #Watches for the dateslider's value (which defaults to minimum of dataset) and starts the editing window there
  observeEvent(input$dateslider,
               window_x_min$x <- input$dateslider)
  #When you click next, it goes to the next window's x coordinate minus any overlap with previous window.
  observeEvent(input$click_Next,
               handlerExpr = {
                 window_x_min$x <- window_x_min$x + time_window() - overlap_window()
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)
               })
  #Same for previous except it goes back in time.
  observeEvent(input$click_Prev,
               handlerExpr = {
                 window_x_min$x <-  window_x_min$x - (time_window() - overlap_window())
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)
               })
  #Waits for click on Next Problem button
  observeEvent(input$click_NextProb,
               handlerExpr = {
                 if (window_x_min$x>=max(probTwilights()$tSecond))
                   #if current value of x axis is equal to or greater than the
                   #the maximum x axis location of any problem, then it does not move and
                   #shows a notification alerting the user.
                 {
                   showNotification(ui = "No problems detected after this point",
                                    type = "warning",
                                    duration = NULL)
                 }
                 else
                   #if first of the next problem values is greater than the current location,
                   #then update the x value to the beginning of that region
                 {window_x_min$x <- probTwilights()$tFirst[probTwilights()$tFirst>window_x_min$x][1]
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)}
                 
               })
  observeEvent(input$click_PrevProb,
               handlerExpr = {
                 if (window_x_min$x<=min(probTwilights()$tFirst, na.rm = TRUE))
                   #if current value of x axis is equal to or less than the
                   #the minimum x axis location of any problem, then it does not move and
                   #shows a notification alerting the user.
                 {
                   showNotification(ui = "No problems detected before this point",
                                    type = "warning",
                                    duration = NULL)
                 }
                 else
                   #if first of the previous problem values is less than the current location,
                   #then update the x value to the beginning of that region
                 {window_x_min$x <- probTwilights()$tFirst[probTwilights()$tFirst<window_x_min$x][1]
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)}
               })


  ###################
  #A table to show what values you have excluded
  #(Removing it speeds up rendering the page.)
  observeEvent(input$render_edits, {
   output$excludedtbl <- renderDT(geolocatordata()[vals$excluded == TRUE, 
                                                   c("datetime", "light"),
                                                   drop = FALSE],
                                  server = TRUE)
  })
  
  ##################
  #Adding true/false excluded column to new reactive data frame
  #This column needs to be in the final downloaded dataset.
  ##################
  geolocatordata_keep <- eventReactive(input$create_data, {
    df <- geolocatordata()
    df$excluded <- vals$excluded
    return(df)

  })
  observeEvent(input$create_data, {
    output$data_preview <- renderDT(geolocatordata_keep(),
                                   server = TRUE)
  })
  ##################
  #Calibration/computation of sun elevation angle from calibration data.
  ##################
  
  #Create a reactive object that is updated
  #when keep values are altered by clicks.
  #It is updated and then the calibration object (calib)
  #is updated too with new values generated by edited_twilights.
  edited_twilights <- reactive ({
    edited_twilights <- TAGS_twilight_calc(datetime = geolocatordata_keep()[geolocatordata_keep()$excluded == FALSE,
                                                                                     "datetime"],
                                           light = geolocatordata_keep()[geolocatordata_keep()$excluded == FALSE,"light"],
                                           LightThreshold = input$light_threshold,
                                           allTwilights = FALSE)
  return(edited_twilights)
    })
  
  calib <- reactive ({
      consecTwilights <- twl()[[2]]
      calib <- subset(consecTwilights,
                      (as.numeric(as.Date(consecTwilights$tSecond)) < as.numeric(input$stop_calib_date))&
                        (as.numeric(as.Date(consecTwilights$tFirst)) > as.numeric(input$start_calib_date))  
    
    )
    return(calib)
    
  })

  #observeEvent says when you click on "calculate" it gives you a new 
  #value for sun angle and updates the number input's manually entered entry.
   observeEvent(input$calculate, {
     elev <- NA
     elev <- getElevation(calib()$tFirst,
                 calib()$tSecond, 
                 calib()$type,
                 known.coord=c(input$calib_lon,
                               input$calib_lat) )[[1]]
     #the [[1]] is necessary to pull out just the median sun angle 
     #and not the rest of the values from this function
    #updateNumericInput puts the newly calculated value into the numeric input field for sunangle.
     updateNumericInput(session,
                       "sunangle", 
                       value = as.numeric(elev))
  })
 
   ##################
   #Get to TAGS format by including interpolations
   ##################   
   #From FLightR documentation:
   #"The fields excluded and interp may have values of TRUE only for twilight > 0."
   #But this does not make sense when we exclude data points, not twilights.
   
   final_TAGS <- reactive({
     #Must merge the raw data with twilights, note whether a value was interpolated.
     raw <- geolocatordata_keep() #raw original values but with true/false excluded column
     #That is how this function differents from FLightR: GeoLight2TAGS
     #(it has no accounting for exclusion except to assume excluded = FALSE)
     gl_twl <- edited_twilights() #Get edited twilights
     raw$twilight <- 0
     twl <- data.frame(datetime = as.POSIXct(c(gl_twl$tFirst, 
                                               gl_twl$tSecond), "UTC"), 
                       twilight = c(gl_twl$type,
                                    ifelse(gl_twl$type == 1, 2, 1)))
     twl <- twl[!duplicated(twl$datetime), ]
     twl <- twl[order(twl[, 1]), ]
     twl$light <- mean(stats::approx(x = raw$datetime,
                                     y = raw$light, 
                                     xout = twl$datetime)$y,
                       na.rm = T)
     tmp01 <- merge(raw,
                    twl,
                    all.y = TRUE,
                    all.x = TRUE)
     out0 <- data.frame(datetime = tmp01[, "datetime"], 
                       light = tmp01[, "light"],
                       twilight = tmp01[, "twilight"], 
                       interp = FALSE, 
                       excluded = tmp01[, "excluded"]) #use the excluded we have created, not assume false
     out0$interp[is.na(out0$excluded)] <- TRUE #values are interpolated where it did not exist in original data.
     out0$excluded[is.na(out0$excluded)] <- FALSE #values from the edited twilights were not excluded and MUST have a value.
     
     #now merge in original twilights and note as excluded, as FlightR at least will account for that.
     gl_twl2 <- twl()[[2]]
     twl2 <- data.frame(datetime = as.POSIXct(c(gl_twl2$tFirst, 
                                               gl_twl2$tSecond), "UTC"), 
                       twilight = c(gl_twl2$type,
                                    ifelse(gl_twl2$type == 1, 2, 1)))
     twl2 <- twl2[!duplicated(twl2$datetime), ]
     twl2 <- twl2[order(twl2[, 1]), ]
     twl2$light <- mean(stats::approx(x = raw$datetime,
                                     y = raw$light, 
                                     xout = twl2$datetime)$y,
                       na.rm = T)
     
     
     tmp02 <- merge(raw,
                    twl2,
                    all.y = TRUE,
                    all.x = TRUE)
     
     out1 <- data.frame(datetime = tmp02[, "datetime"], 
                        light = tmp02[, "light"],
                        twilight = tmp02[, "twilight"], 
                        interp = FALSE, 
                        excluded = tmp02[, "excluded"]) #use the excluded we have created, not assume false
     out1$interp[is.na(out1$excluded)] <- TRUE #values are interpolated where it did not exist in original data.
     
     #return all rows from x (the full set of twilights) but only use twilight values from the good ones.
     out2 <- left_join(x = out1, #x is the full set, makes sure you get the whole set back.
                       y = out0[,c("datetime", 
                                   "light",
                                   "interp")], #y are the edited twilights, but we don't want their twilight or exclusion values.
                       by = c("datetime", #join on datetime, light, and interpolation.
                              "light",
                              "interp"))
     
     #It results in the edited, good twilights having NA.
     #so where is.na then replace NA with FALSE for excluded.
     out2$excluded[is.na(out2$excluded)] <- FALSE
     
     #Order final result.
     out <- out2[order(out2[, 1]), ]
     
     #format it to correct datetime format.
     out[, 1] <- format(out[, 1], format = "%Y-%m-%dT%H:%M:%S.000Z")
     
     return(out)
   })
   

  ##################
  #MAP
  ##################

   #On clicking the actionButton update_map,
   #the map is generated or refreshed with new values.
   #having this isolated in observeEvent keeps it from updating
   #constantly and using more server time.
   
   #Get coordinates for all consecutive twilights.
   coord <- reactive({
     ctwl <- edited_twilights()
     coord <- GeoLight::coord(tFirst = ctwl$tFirst,
           tSecond = ctwl$tSecond,
           type = ctwl$type,
           degElevation=input$sunangle)
     coord.df <- data.frame(coord)
     coord.df$long <- coord.df$lon #rename default to match what addMarkers in leaflet() lines below requires.
     coord.df$lon <- NULL #delete old column
     return(coord.df)
   })
   
   observeEvent(input$update_map, {
     output$mymap <- renderLeaflet({
       

       #run the leaflet function
       leaflet() %>%
         #add map tiles
         addProviderTiles(provider = "Stamen.TonerLite",
                         options = providerTileOptions(noWrap = TRUE)
         ) %>%
         #add the calculated coordinates based on edited twilights
         addMarkers(data = coord())
     })
   })
   

   


  
  ##################
  #Code to do downloading here and in UI adapted from here:
  #https://stackoverflow.com/questions/41856577/upload-data-change-data-frame-and-download-result-using-shiny-package
  ##################
  
  output$downloadData <- downloadHandler(
    
    filename = function() { 
      paste("TAGS_format_data-", 
            input$filename,
            Sys.Date(),
            ".csv",
            sep="")
    },
    
    content = function(file) {
      
      write.csv(final_TAGS(), 
                file,
                quote = FALSE,
                row.names = FALSE)
      
    })
   
   output$downloadDataCoord <- downloadHandler(
     
     filename = function() { 
       paste("coord_data-", 
             input$filename,
             Sys.Date(), ".csv", sep="")
     },
     
     content = function(file) {
       
       write.csv(coord(), 
                 file,
                 quote = FALSE,
                 row.names = FALSE)
       
     })
   
   output$downloadDataTwilights <- downloadHandler(
     
     filename = function() { 
       paste("twilights_data-", 
             input$filename,
             Sys.Date(), ".csv", sep="")
     },
     
     content = function(file) {
       
       write.csv(edited_twilights(),
                 file,
                 quote = FALSE,
                 row.names = FALSE)
       
     })
}

#Run the application 
shinyApp(ui = ui, 
         server = server)


