ui <- fluidPage(
  
  titlePanel("Ganttrify!"),
  
  sidebarLayout(
    sidebarPanel(
      shiny::fileInput(inputId = "project_file", label = "Upload csv of project"),
      shiny::fileInput(inputId = "spot_file", label = "Upload csv of spots"),
      shiny::dateInput(inputId = "start_date", label = "Starting date of the project")
    ),
    
    mainPanel(
      shiny::plotOutput(outputId = "gantt"),
      shiny::tableOutput(outputId = "current_project_table"),
      shiny::tableOutput(outputId = "current_spots_table")
    )
  )
)