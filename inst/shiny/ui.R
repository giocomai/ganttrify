ui <- fluidPage(
  
  titlePanel("Ganttrify!"),
  
  sidebarLayout(
    sidebarPanel(
      shiny::fileInput(inputId = "project_file", label = "Upload csv of project"),
      shiny::fileInput(inputId = "spot_file", label = "Upload csv of spots"),
      shiny::dateInput(inputId = "start_date", label = "Starting date of the project"),
      shiny::checkboxInput(inputId = "month_number", label = "Include month numbers on top", value = TRUE),
      shiny::checkboxInput(inputId = "mark_quarters", label = "Add vertical lines to mark quarters", value = FALSE),
      shiny::numericInput(inputId = "size_wp", label = "Thickness of the line for working packages", value = 6),
      shiny::numericInput(inputId = "size_activity", label = "Thickness of the line for activities", value = 4),
      shiny::sliderInput(inputId = "size_text_relative", label = "Relative size of all text", value = 100, min = 1, max = 500, round = TRUE, post = "%"),
      shiny::HTML("<hr />"),
      shiny::numericInput(inputId = "download_width",
                          label = "Download width (in cm)",
                          value = 18),
      shiny::numericInput(inputId = "download_height",
                          label = "Download height (in cm)",
                          value = 13.5),
      shiny::downloadButton(outputId = "download_gantt",
                     label =  "Download Gantt chart")
    ),
    mainPanel(
      shiny::plotOutput(outputId = "gantt"),
      shiny::tableOutput(outputId = "current_project_table"),
      shiny::tableOutput(outputId = "current_spots_table")
    )
  )
)