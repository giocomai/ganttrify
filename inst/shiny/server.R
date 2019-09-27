server <- function(input, output) {
  
  
  current_project_df <- shiny::eventReactive(input$project_file, {
    
    req(input$project_file)
    
    readr::read_csv(file = input$project_file$datapath)
  })
  
  current_spots_df <- shiny::eventReactive(input$spot_file, {
    
    req(input$spot_file)
    
    readr::read_csv(file = input$spot_file$datapath)
  })
  
  shiny::observeEvent(eventExpr = input$project_file, {
    output$gantt <- renderPlot({
      ganttrify::ganttrify(df = current_project_df(),
                           start_date = input$start_date)
    })
  })
  
  shiny::observeEvent(eventExpr = input$spot_file, {
    output$gantt <- renderPlot({
      ganttrify::ganttrify(df = current_project_df(),
                           spots = current_spots_df(),
                           start_date = input$start_date)
    })
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
      ganttrify::ganttrify(df = current_project_df(),
                           start_date = input$start_date,
                           spots = current_spots_df())
  })
  
}