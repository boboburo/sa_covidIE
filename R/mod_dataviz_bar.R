#' dataviz_bar UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_dataviz_bar_ui <- function(id, label = "County Plot"){
  ns <- NS(id)
  
  end_date <- max(dailycases$time_stamp)
  start_date <- end_date - days(30)
  
  
  tagList(
    sliderInput(ns("slider"), min = min(dailycases$time_stamp), 
                max = max(dailycases$time_stamp), value = c(start_date, end_date),label  = label),
    plotOutput(ns("out"))
    )
}
    
#' dataviz_bar Server Function
#'
#' @noRd 
mod_dataviz_bar_server <- function(input, output, session){
  ns <- session$ns
  output$out <- renderPlot({
    
    dailycases %>%
      filter(time_stamp >= input$slider[1]) %>%
      filter(time_stamp <= input$slider[2]) %>%
      group_by(time_stamp) %>% 
      summarise(cnt = sum(day_cases)) %>%
      ungroup () %>%
      ggplot(aes(x = time_stamp, y = cnt)) + 
      geom_col()
    
  })
}
    
## To be copied in the UI
# mod_dataviz_bar_ui("dataviz_bar_ui_1")
    
## To be copied in the server
# callModule(mod_dataviz_bar_server, "dataviz_bar_ui_1")
 
