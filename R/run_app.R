#' Run the Shiny Application
#'
#' @param ... A series of options to be used inside the app.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#' 
#' 
#' 
source(here("R","fct_load_data.R"))
dailycases <- load_covid_ireland()

run_app <- function(
  ...
) {

  
  with_golem_options(
    app = shinyApp(
      ui = app_ui, 
      server = app_server

    ), 
    golem_opts = list(...)
    
    
    
  )
}
