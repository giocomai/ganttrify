server <- function(input, output) {
  
  
  current_project_df <- shiny::eventReactive(input$project_file, {
    
    in_file <- input$project_file
    
    if (is.null(in_file)) return(NULL)
    
    readr::read_csv(file = in_file$datapath)
  })
  
  current_spots_df <- shiny::eventReactive(input$spot_file, {
    
    in_file <- input$spot_file
    
    if (is.null(in_file)) return(NULL)
    
    readr::read_csv(file = in_file$datapath)
  })
    
  
  output$current_project_table <- renderTable(
    if (is.null(current_project_df())==FALSE) {
      current_project_df()
      }
  )
  
  output$current_spots_table <- renderTable(
    if (is.null(current_spots_df())==FALSE) {
      current_spots_df()
    }
  )

  output$gantt <- renderPlot({

    if (is.null(current_project_df())==FALSE) {
      ganttrify::ganttrify(df = current_project_df(),
                           spots = current_spots_df(),
                           start_date = input$start_date)
    }
  })
  
}