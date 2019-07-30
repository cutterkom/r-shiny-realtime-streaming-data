# R-Shiny Template for real time data

This is a very basic template for streaming realtime data in [R-Shiny](https://shiny.rstudio.com/). 

[Demo](http://apps.katharinabrunner.de/r-shiny-realtime-streaming-data/)

It has two components: 

1. Generating a data point every two seconds

2. Plotting the data with three packages: [ggplot2](https://ggplot2.tidyverse.org/), [plotly](https://plot.ly/) and [scatterD3](https://juba.github.io/scatterD3/)


## 1) Generating new data

First, I initialize an empty dataframe as a [``reactiveValues`` object](https://shiny.rstudio.com/articles/reactivity-overview.html). It receives and stores the new data points.

```
# initialize an empty dataframe as a reactiveValues object.
# it is going to store all upcoming new data

values <- reactiveValues(df = data.frame(x = NA, y = NA))
```

Then, random data is saved in a `reactive values` dataframe. This `values$df` will be incrementally filled every two seconds by using [`observeEvent()`](https://shiny.rstudio.com/reference/shiny/1.0.0/observeEvent.html):

```
observeEvent(reactiveTimer(2000)(),{ # Trigger every 2 seconds
  values$df <- isolate({
    # get and bind the new data
      values_df <- rbind(values$df, get_new_data()) %>% filter(!is.na(x))
    })
})
```

## 2) Plotting the data

After receiving new data in the `reactive values` dataframe, the app plots the data with three packages. 

The `ggplot2` example:

```
  # create ggplot2 chart 
  output$plot <- renderPlot({
    
    x_axis_start <- as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin="1970-01-01")
    x_axis_end <-  as.POSIXct(min(values$df$x), format = "%Y-%m-%d", origin="1970-01-01") + 1000
    y_axis_range <- c(0, 70)
    
  values$df %>% 
  ggplot(aes(x = as.POSIXct(x, format = "%Y-%m-%d", origin="1970-01-01"), y = y)) + 
  geom_point() + 
  expand_limits(x = c(x_axis_start, x_axis_end), y = y_axis_range)
})
```