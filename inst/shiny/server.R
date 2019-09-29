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
                           start_date = input$start_date,
                           mark_quarters = input$mark_quarters,
                           month_number = input$month_number,
                           size_wp = input$size_wp,
                           size_activity = input$size_activity,
                           size_text_relative = input$size_text_relative/100
      )
    })
  })
  
  shiny::observeEvent(eventExpr = input$spot_file, {
    output$gantt <- renderPlot({
      ganttrify::ganttrify(df = current_project_df(),
                           start_date = input$start_date,
                           spots = current_spots_df(),
                           mark_quarters = input$mark_quarters,
                           month_number = input$month_number,
                           size_wp = input$size_wp,
                           size_activity = input$size_activity,
                           size_text_relative = input$size_text_relative/100
      )
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

  gantt_chart <- shiny::reactive({
    ganttrify::ganttrify(df = current_project_df(),
                         start_date = input$start_date,
                         spots = current_spots_df(),
                         mark_quarters = input$mark_quarters,
                         month_number = input$month_number,
                         size_wp = input$size_wp,
                         size_activity = input$size_activity,
                         size_text_relative = input$size_text_relative/100
    )
  })
  
  output$gantt <- renderPlot({
    gantt_chart()
  })
  
  output$download_gantt <- downloadHandler(filename = "gantt.png",
                                           content = function(con) {
                                             ggplot2::ggsave(filename = con,
                                                             plot = gantt_chart(),
                                                             width = input$download_width,
                                                             height = input$download_height,
                                                             units = "cm")
                                           }
  )
  
  
}