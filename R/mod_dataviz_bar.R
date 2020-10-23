#' dataviz_bar UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' 

rm(mod_dataviz_bar_server, mod_dataviz_bar_ui, barApp)
library(ggplot2)
library(dplyr)


mod_dataviz_bar_ui <- function(id){
  
  end_date <- max(dailycases$time_stamp)
  
tagList(
    plotOutput(NS(id,"plot1"))
)
}
    
#' dataviz_bar Server Function
#'
#' @noRd 
mod_dataviz_bar_server <- function(id,cnty="Dublin",type = "bar",r){
  moduleServer(id, function(input, output, session){
    
  #Determine the county click on the scatter plot  
  clicked_cnty <- reactive(if(length(r$cnty_point())==0){
    cnty}else{r$cnty_point()})
  
  start_date <- reactive(ymd(r$focus_date()[1]))
  end_date <- reactive(ymd(r$focus_date()[2]))
  days_between <- reactive(as.integer(end_date() - start_date()))
  
  output$plot1<- renderPlot({
    
    if(type == "bar"){
    
      plot_title <- reactive(glue::glue(
        'Daily ',
        'count of cases ',
        'in {clicked_cnty()}'))
      plot_subtitle <- reactive(glue::glue(
        '{days_between()} days up until {format(end_date(), "%A, %B %d, %Y")}'))
    
      plot <- dailycases %>%
        dplyr::filter(time_stamp <= end_date()) %>%
        dplyr::filter(time_stamp >= (end_date()- lubridate::days(days_between()))) %>%
        dplyr::filter(county_name == clicked_cnty()) %>% 
        ggplot2::ggplot(aes(x = time_stamp, y = day_cases)) + 
        ggplot2::geom_col() +
        ggplot2::labs(title = plot_title(),
                      subtitle = plot_subtitle())
      
      if(r$smth_7() == TRUE){
        plot <- plot +
          geom_line(aes(y = day_cases_7x2), color = "green")
      }
      
      if(r$smth_14() == TRUE){
        plot <- plot +
          geom_line(aes(y = day_cases_14x2), color = "blue")
        
      }
      
      
    }
      
      if(type == "line"){
        
        
        plot_title <- reactive(glue::glue(
          'Trend of cases per 100k ',
          'in {clicked_cnty()}'))
        plot_subtilte <- reactive(glue::glue(
          '{days_between()} days up until {format(end_date(), "%A, %B %d, %Y")}'))
        
        plot <- dailycases %>%
          dplyr::filter(time_stamp <= end_date()) %>%
          dplyr::filter(time_stamp >= (end_date()- lubridate::days(days_between()))) %>%
          dplyr::filter(county_name == clicked_cnty()) %>% 
          ggplot2::ggplot(aes(x = time_stamp, y = cumm_7_inc)) + 
          ggplot2::geom_line() +
          ggplot2::labs(title = plot_title(),
                        subtitle = plot_subtilte(),
                        y = "7 days cases per 100k",
                        x = "")
        
        if(r$smth_7() == TRUE){
          plot <- plot +
            geom_line(aes(y = cumm_7_inc_7x2), color = "green")
        }
        
        if(r$smth_14() == TRUE){
          plot <- plot +
            geom_line(aes(y = cumm_14_inc_14x2), color = "blue")
          
        }

      }
    
    plot
    
  })
})
}

barApp <- function() {
  ui <- fluidPage(
    mod_dataviz_bar_ui("plot_test")
  )
  server <- function(input, output, session) {
    r = reactiveValues()
    r$cnty_point <- reactive("Dublin")
    r$focus_date <- reactive(c("2020-08-01","2020-09-28"))
    r$smth_7 <- reactive(TRUE)
    r$smth_14 <- reactive(TRUE)
    
    mod_dataviz_bar_server("plot_test", cnty = "Dublin", type = "bar",r)
  }
  shinyApp(ui, server)  
}

barApp()
    
## To be copied in the UI
# mod_dataviz_bar_ui("dataviz_bar_ui_1")
    
## To be copied in the server
# callModule(mod_dataviz_bar_server, "dataviz_bar_ui_1")
 
