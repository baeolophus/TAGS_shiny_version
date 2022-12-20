#code modified from: https://gallery.shinyapps.io/106-plot-interaction-exclude/
#and https://shiny.rstudio.com/reference/shiny/latest/sliderInput.html

library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

## Only run examples in interactive R sessions

  ui <- fluidPage(

  )
  
  # Server logic
  server <- function(input, output) {

  }
  
  # Complete app with UI and server components
  shinyApp(ui, server)
}

ui <- fluidPage(
  fluidRow(
    column(width = 6,
           plotOutput("plot1", height = 350,
                      click = "plot1_click",
                      brush = brushOpts(
                        id = "plot1_brush"
                      )
           ),
           actionButton("exclude_toggle", "Toggle points"),
           actionButton("exclude_reset", "Reset")
    )
  )
  sliderInput("obs", "Number of observations:",
              min = 0, max = 1000, value = 500
  ),
  plotOutput("plot1")
)

server <- function(input, output) {
  # For storing which rows have been excluded
  vals <- reactiveValues(
    keeprows = rep(TRUE, nrow(mtcars))
  )
  

  output$plot1 <- renderPlot({
    # Plot the kept and excluded points as two separate data sets
    keep    <- mtcars[ vals$keeprows, , drop = FALSE]
    exclude <- mtcars[!vals$keeprows, , drop = FALSE]
    
    ggplot(keep, aes(wt, mpg)) + geom_point() +
      geom_smooth(method = lm, fullrange = TRUE, color = "black") +
      geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
      coord_cartesian(xlim = c(1.5, 5.5), ylim = c(5,35))
  })
  
  # Toggle points that are clicked
  observeEvent(input$plot1_click, {
    res <- nearPoints(mtcars, input$plot1_click, allRows = TRUE)
    
    vals$keeprows <- xor(vals$keeprows, res$selected_)
  })
  
  # Toggle points that are brushed, when button is clicked
  observeEvent(input$exclude_toggle, {
    res <- brushedPoints(mtcars, input$plot1_brush, allRows = TRUE)
    
    vals$keeprows <- xor(vals$keeprows, res$selected_)
  })
  
  # Reset all points
  observeEvent(input$exclude_reset, {
    vals$keeprows <- rep(TRUE, nrow(mtcars))
  })
  
}

shinyApp(ui, server)
