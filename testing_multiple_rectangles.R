library(shiny)
library(ggplot2)

ui <- basicPage(
  plotOutput("plot1",
             click = "plot_click",
             dblclick = "plot_dblclick",
             hover = "plot_hover",
             brush = "plot_brush"
  ),
  verbatimTextOutput("info")
)

server <- function(input, output) {
  library(jpeg)
  prev_vals <- NULL
  structures <- reactiveValues(data = data.frame(box_id = numeric(),
                                                 xmin = numeric(),
                                                 ymin = numeric(), 
                                                 xmax = numeric(), 
                                                 xmax = numeric()))

  output$plot1 <- renderPlot({
    df <- data.frame(
      gp = factor(rep(letters[1:3], each = 10)),
      y = rnorm(30)
    )
    plotting <- ggplot() +
      coord_cartesian(xlim = c(0,4),
                      ylim = c(-1,1))+
      geom_point(data = df,
                 mapping = aes(gp, y))
    if (nrow(structures$data) > 0) {
      r <- structures$data
      plotting +
      geom_rect(data = r,
                  mapping = aes(xmin = xmin,
                                xmax = xmax,
                                ymin = ymin,
                                ymax = ymax),
                  col = "red")
    }

    
  })
  
  #better this way: https://stackoverflow.com/questions/22915337/if-else-condition-in-ggplot-to-add-an-extra-layer in first answer, but still very slow.
  
  observe({
    e <- input$plot_brush
    if (!is.null(e)) {
      vals <- data.frame(xmin = round(e$xmin, 1),
                         ymin = round(e$ymin, 1), 
                         xmax = round(e$xmax, 1),
                         ymax = round(e$ymax, 1))
      if (identical(vals,prev_vals)) return() #We dont want to change anything if the values havent changed.
      structures$data <- rbind(structures$data,
                               cbind(data.frame(box_id = nrow(structures$data)+1),
                                     vals))
      prev_vals <<- vals
    }
  })
  
  output$info <- renderText({
    
    xy_str <- function(e) {
      if(is.null(e)) return("NULL\n")
      paste0("x=", round(e$x, 1), " y=", round(e$y, 1), "\n")
    }
    
    
    xy_range_str <- function(e) {
      if(is.null(e)) return("NULL\n")
      paste0("xmin=", round(e$xmin, 1), " xmax=", round(e$xmax, 1), 
             " ymin=", round(e$ymin, 1), " ymax=", round(e$ymax, 1))
    }
    
    paste0(
      "click: ", xy_str(input$plot_click),
      "dblclick: ", xy_str(input$plot_dblclick),
      "hover: ", xy_str(input$plot_hover),
      "brush: ", xy_range_str(input$plot_brush)
    )
    
  })
}

shinyApp(ui, server)
