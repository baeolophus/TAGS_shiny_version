library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

ui <- fluidPage(
  fluidRow(
    actionButton("click_Next", "Next 1 unit"),
    
    actionButton("click_Prev", "Prev 1 unit"),
    
    actionButton("click_NextProb", "Next problem"),
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

server <- function(input, output) {
  

  
  # -------------------------------------------------------------------
  # Linked plots (middle and right)
  ranges2 <- reactiveValues(x = NULL, y = NULL)
  
  output$plot2 <- renderPlot({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point()
  })
  
  output$plot3 <- renderPlot({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point() +
      coord_cartesian(xlim = ranges2$x,
                      ylim = ranges2$y,
                      expand = FALSE)
  })
  
  brush <- reactive({brush <- input$plot2_brush})
  
  # When a double-click happens, check if there's a brush on the plot.
  # If so, zoom to the brush bounds; if not, reset the zoom.
  observe({
  #  brush <- input$plot2_brush
    if (!is.null(brush())) {
      ranges2$x <- c(brush()$xmin, brush()$xmax)
      ranges2$y <- c(brush()$ymin, brush()$ymax)
      
    } else {
      ranges2$x <- NULL
      ranges2$y <- NULL
    }
  })
  observeEvent(input$click_Next,
               handlerExpr = {
                 ranges2$x <- ranges2$x + 0.5 #So this should be windowsize - overlap
               })
  observeEvent(input$click_Prev,
               handlerExpr = {
                 ranges2$x <- ranges2$x - 1 #ditto
               })
  observeEvent(input$click_NextProb,
               handlerExpr = {
                 ranges2$x <- c(problem_values[problem_values>max(ranges2$x)][1],
                                problem_values[problem_values>max(ranges2$x)][1]+1) #this number is the width of the window
                 

                 #need to add what happens when you get to end of problems.
                 #eventually could add a "fixed problem" column to skip.
               })
}

x <- c(1,2)
problem_values <- c(1,2.4,5)
max(x)
problem_values[problem_values>max(x)][1]
which.min(abs(x-problem_values))

shinyApp(ui, server)
