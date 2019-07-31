library(shiny)
library(tidyverse)
library(plotly)
library(scatterD3)


ui <- shinyServer(fluidPage(
  
  h1("Template for plotting real-time data in R with Shiny"),
  
  p("Task: Every two seconds, plot a new random point."),
  p("It is accomplished by combining `reactiveValues()`, an object that collects the existing and incoming data, with `observeEvent()`, that executes data fetching proccess every two seconds."
  ),
  a(href = "https://github.com/cutterkom/r-shiny-realtime-streaming-data", "More information in the Readme file on Github."),
  
  
  h2("ggplot2 Library"),
  plotOutput("plot"),
  
  h2("Plotly Library"),
  plotlyOutput("plotly"),
  
  h2("D3"),
  scatterD3Output("d3")
  
))


server <- shinyServer(function(input, output, session) {
  # helper: shut down Shiny session in RStudio, when you close the browser tab
  session$onSessionEnded(stopApp)
  
  # function to create a dataframe with column x as a random number and y as the current timestamp
  get_new_data <- function() {
    y = sample(10:70, 1) # draw a random number between 10 and 70
    x = as.POSIXct(Sys.time(), format = "%Y-%m-%d %H%m", origin = "1970-01-01")
    data.frame(x, y)
  }
  
  # initialise an empty dataframe as a reactiveValues object.
  # it is going to store all upcoming new data
  values <- reactiveValues(df = data.frame(x = NA, y = NA))
  
  # call the function get_new_data() every two seconds
  # and bind the resulting dataframe to the reactiveValues dataframe
  observeEvent(reactiveTimer(2000)(), {
    # Trigger every 2 seconds
    values$df <- isolate({
      # get and bind the new data
      rbind(values$df, get_new_data()) %>%
        filter(!is.na(x)) # filter the first value to prevent a first point in the middle of the plot
    })
  })
  
  # create ggplot2 chart
  output$plot <- renderPlot({
    x_axis_start <-
      as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin = "1970-01-01")
    x_axis_end <-
      as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin = "1970-01-01") + 200
    y_axis_range <- c(0, 70)
    
    ggplot(data = values$df, aes(
      x = as.POSIXct(x, format = "%Y-%m-%d", origin = "1970-01-01"),
      y = y
    )) +
      geom_point() +
      expand_limits(x = c(x_axis_start, x_axis_end), y = y_axis_range)
  })
  
  # create plotly chart
  output$plotly <- renderPlotly({
    x_axis_start <-
      as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin = "1970-01-01")
    x_axis_end <-
      as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin = "1970-01-01") + 200
    
    
    plot_ly(
      data = values$df,
      x = ~ as.POSIXct(x, format = "%Y-%m-%d", origin = "1970-01-01"),
      y = ~ y,
      type = "scatter",
      mode = "markers"
    ) %>%
      layout(xaxis = list(
        range =  c(x_axis_start, x_axis_end),
        type = "date"
      ),
      yaxis = list(range = c(0, 70)))
    
  })
  
  # create D3 chart
  output$d3 <- renderScatterD3({
    scatterD3(
      data = values$df,
      x = x,
      y = y,
      xlim = c(min(values$df$x), min(values$df$x) + 200),
      ylim = c(0, 70)
    )
  })
  
})

shinyApp(ui = ui, server = server)
