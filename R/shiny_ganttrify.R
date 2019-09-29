#' Run a web app to customise Gantt charts
#'
#' Creates Gantt with `ganttrify` without coding. 
#'
#' @return Nothing, used for its side effects. 
#'
#' @examples
#' ganttrify(ganttrify::test_project)
#'
#' @export
#'
#'

shiny_ganttrify <- function() {
  shiny::runApp(appDir = system.file("shiny", package = "ganttrify"),
                display.mode = "normal")
}