#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    fluidPage(
      
      fluidRow(wellPanel("Covid Ireland")),
      fluidRow(wellPanel("Scatter Plot Here")),
      fluidRow(column(width = 3, wellPanel("Bottom row, column 1, width 4")),
               column(width = 9, wellPanel(
                 tabsetPanel(type = "tabs",
                             tabPanel("Daily Rate", 
                                      mod_dataviz_bar_ui("dataviz_bar_ui_1")),
                             tabPanel("Explore Cases",   
                                      mod_dataviz_bar_ui("dataviz_bar_ui_2", label = "Something Else")))
               ))
      ))
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'covidIE'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

