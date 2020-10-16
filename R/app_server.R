#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here

  callModule(mod_dataviz_bar_server, "dataviz_bar_ui_1")
  callModule(mod_dataviz_bar_server, "dataviz_bar_ui_2")
  
}
