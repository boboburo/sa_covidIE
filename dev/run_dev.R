# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Detach all loaded packages and clean your environment
library(shiny)
library(reactlog)
reactlog::reactlog_enable()
options(shiny.reactlog=TRUE)

golem::detach_all_attached()
golem::document_and_reload()
library(shiny)
library(reactlog)
reactlog::reactlog_enable()
options(shiny.reactlog=TRUE)
run_app()
#shiny::reactlogShow()




if (FALSE) {
  library(shiny)
  library(reactlog)
  
  # tell shiny to log reactivity
  reactlog_enable()
  
  # run a shiny app
  app <- system.file("examples/01_hello", package = "shiny")
  runApp(app)
  
  # once app has closed, display reactlog
  shiny::reactlogShow()
}