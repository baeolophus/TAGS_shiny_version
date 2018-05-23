library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

ui <- fluidPage(
  fluidRow(
    actionButton("click_Prev", "Previous window"),
    actionButton("click_Next", "Next window"),
    actionButton("click_PrevProb", "Previous problem"),
    actionButton("click_NextProb", "Next problem"),
    uiOutput("dateslider"),
    numericInput("time_window", "Editing window", value = 1),
    numericInput("overlap_window", "What overlap with previous window?", value = 0),
    column(width = 8, class = "well",
           h4("Left plot controls right plot"),
           fluidRow(
             column(width = 6,
                    plotOutput("plot2", height = 300,
                               brush = brushOpts(
                                 id = "plot2_brush",
                                 resetOnNew = TRUE
                               )
                    )
             ),
             column(width = 6,
                    plotOutput("plot3", height = 300)
             )
           )
    )
    
  )
)

server <- function(input, output, session) {
  

  
  # -------------------------------------------------------------------
  # Linked plots (middle and right)
  #create a user interface dynamic slider based on reactive data
  
  window_x_min <- reactiveValues(x = min(mtcars$wt))
  
  output$dateslider <- renderUI({
    sliderInput("dateslider",
                "Window start",
                min = min(mtcars$wt),
                max = max(mtcars$wt),
                value = window_x_min$x, #This sets the initial value ONLY
                #to first timestamp of the dataset
                width = '100%')
  })

  
  output$plot2 <- renderPlot({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point()
  })
  
  output$plot3 <- renderPlot({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point() +
      coord_cartesian(xlim = c(window_x_min$x,
                               window_x_min$x+input$time_window),
                      expand = FALSE)
  })
  
  observeEvent(input$dateslider,
               window_x_min$x <- input$dateslider)
  observeEvent(input$click_Next,
               handlerExpr = {
                 window_x_min$x <- window_x_min$x + input$time_window - input$overlap_window
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)
               })
  observeEvent(input$click_Prev,
               handlerExpr = {
                 window_x_min$x <-  window_x_min$x - (input$time_window - input$overlap_window)
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)
               })
  observeEvent(input$click_NextProb,
               handlerExpr = {
                 if (window_x_min$x>=max(problem_values))
                   #if the next problem value is less than the minimum of the dataset
                 {
                 showNotification(ui = "No problems detected after this point",
                                  type = "warning",
                                  duration = NULL)
                   }
                 else
                   #then update the x value to the beginning
                 {window_x_min$x <- problem_values[problem_values>window_x_min$x][1]
                 updateSliderInput(session,
                                   "dateslider",
                                   value = window_x_min$x)}

               })
  observeEvent(input$click_PrevProb,
               handlerExpr = {
                 if (window_x_min$x<=min(problem_values))
                   #if the next problem value is less than the minimum of the dataset
                 {
                   showNotification(ui = "No problems detected before this point",
                                    type = "warning",
                                    duration = NULL)
                   }
                   else
                   #then update the x value to the beginning
                   {window_x_min$x <- problem_values[problem_values<window_x_min$x][1]
                   updateSliderInput(session,
                                     "dateslider",
                                     value = window_x_min$x)}
               })
}

problem_values <- c(2.4,5)

problem_values < 1

shinyApp(ui, server)
