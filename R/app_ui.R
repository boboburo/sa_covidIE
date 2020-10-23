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
    shinyUI(
      fluidPage(theme = shinythemes::shinytheme("flatly"),
                tags$title("Analyze COVID Numbers in Ireland by County"),
                      column(width = 12,
                             h1("COVID Numbers in Ireland by County"),
                             HTML(
                               "<div class='alert alert-info'>",
                               "The scatter plot is a recreation of this <a href='https://www.ft.com/content/a2dbf1c0-dcce-4eae-b1f6-f2c31bf0db8a' class='alert-link'>plot</a> from the Finanical Times.",
                               "</div>"
                             )),
                fluidRow(
                  column(width = 12,
                         mod_dataviz_scatter_ui("dataviz_scatter_ui_1"))),
                fluidRow(
                  
                    
                    # Sidebar with a slider input
                    column(width = 3, 
                      wellPanel(
                       # tags$style(".well {background-color:#33FFC4;}"),
                        sliderInput("slider_dlb_date",label = "Date Range", 
                                    value = c(min(dailycases$time_stamp),max(dailycases$time_stamp)),
                                    min = min(lubridate::ymd("2020-04-01")), 
                                    max = max(dailycases$time_stamp),
                                    dragRange = FALSE,
                                    timeFormat = "%Y-%m-%d",
                                    animate = FALSE),
                        checkboxInput("ck_7day", "7 day smoothed", FALSE),
                        checkboxInput("ck_14day", "14 day smoothed", FALSE)
                        )),
                    
                    # Show a plot of the generated distribution
                    column(width = 9,
                      tabsetPanel(
                        tabPanel("Avg Rates per 100k", mod_dataviz_bar_ui("dataviz_bar_ui_1")),
                        tabPanel("Daily Case Counts",mod_dataviz_bar_ui("dataviz_bar_ui_2"))
                        )
                    )#column
               
                )#fluidRow
      )#fluidPage
    )#shinyUi
  )#tagLst
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

