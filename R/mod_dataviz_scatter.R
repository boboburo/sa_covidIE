#' dataviz_scatter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 

rm(mod_dataviz_scatter_server, mod_dataviz_scatter_ui , scatterApp)
mod_dataviz_scatter_ui <- function(id){
  tagList(
      plotOutput(NS(id, "plotS"),
                 click = clickOpts(id = NS(id,"plotS_click"))
  ))
}
    
#' dataviz_scatter Server Function
#'
#' @noRd 
#' 
mod_dataviz_scatter_server <- function(id,r){
  moduleServer(id,function(input, output, session){

  #for rates per 100,000
  pop_grp <- 100000
  
  #grab data for plot, currently the last day. 
  last_day_cases <- dailycases %>% filter(time_stamp == max(time_stamp))
  
  strip_infs_na <- !(
    is.na(rowSums(last_day_cases %>% select(plt1_x,plt1_y))) | 
      is.infinite(rowSums(last_day_cases %>% select(plt1_x, plt1_y)))
  )
  
  last_day_cases <- last_day_cases[strip_infs_na,]
  
  #create the annotation values used for HIGH RISING, LOW RISING labels
  xrng <- last_day_cases %>%
      dplyr::summarise(rng = range(plt1_x)) %>% unlist()
  
  yrng <- last_day_cases %>%
      dplyr::summarise(rng = range(plt1_y))%>% unlist()
  
  if(yrng[1] > -0.25){yrng[1]= -0.25}
  if(yrng[2] <  0.25){yrng[2]=  0.25}
  
  #Work out which county point is selected
  r$cnty_point <- reactive({
    nearPoints(last_day_cases,
               input$plotS_click, xvar = "plt1_x", yvar = "plt1_y" )$county_name})
    

  output$plotS <- renderPlot({
    
      #base plot
      plot <- last_day_cases %>%
        ggplot2::ggplot(aes(x = plt1_x,
                   y = plt1_y)) +
        ggplot2::geom_point(color = "red", aes(size = population_census16)) +
        ggrepel::geom_text_repel(aes(label = county_name), size =3)
    
      #add hline, labels and scale the axis
      plot <- plot + 
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey24", alpha = 0.8, size = 1) +
        ggplot2::labs(x = paste("Count of 7 days cases, per 100k people"),
             y = paste("Week on-week change"),
             size = "Population Size ~",
             subtitle = "Click on county to explore in detail below",
             title = "Scatter plot of COVID rates per 100k (based on 7 day cummulative).") +
        ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) + 
        ggplot2::scale_size_continuous(range = c(0.1,10), breaks = 10000 * c(5,10,50), 
                                     labels  = c("50k","100k", "500k"))
      
  
    
      #add annotations
      clr = "red3"
      sz = 4
        
      plot <- plot +
        ggplot2::annotate("text", x = xrng[2], y = yrng[2], label = "HIGHER\nRISING", 
                 size = sz, color = clr, hjust = 1, vjust = 1.0) +
        ggplot2::annotate("text", x = xrng[2], y = yrng[1], label = "HIGHER\nFALLING", 
                 size = sz, color = clr, hjust = 1, vjust = -0.5) +
        ggplot2::annotate("text", x = xrng[1], y = yrng[2], label = "LOWER\nRISING", 
               size = sz, color = clr, hjust = 0, vjust = 1.0) +
        ggplot2::annotate("text", x = xrng[1], y = yrng[1], label = "LOWER\nFALLING", 
                 size = sz, color = clr, hjust = 0, vjust = -0.5)
      
      plot + ggplot2::theme(legend.position="top",
                            axis.title.x = element_text(size = 14),
                            axis.title.y = element_text(size =14),
                            axis.text = element_text(size = 10)) 
    })# end plot 
  })#end moduleServer
}
  
scatterApp <- function() {
  ui <- fluidPage(
    mod_dataviz_scatter_ui("plot_test")
  )
  server <- function(input, output, session) {
    r <- reactiveValues()
    mod_dataviz_scatter_server("plot_test",r)
  }
  shinyApp(ui, server)  
}

scatterApp()

## To be copied in the UI
# mod_dataviz_scatter_ui("dataviz_scatter_ui_1")
    
## To be copied in the server
# callModule(mod_dataviz_scatter_server, "dataviz_scatter_ui_1")
 
