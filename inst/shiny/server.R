server <- function(input, output) {
  
  current_project_df <- shiny::eventReactive(
    {
      input$go
      input$by_date_radio
      input$precision_radio
    }, {
    
    if (input$source_type=="demo") {
      if (input$by_date_radio=="By date") {
        if (input$precision_radio=="Day") {
          ganttrify::test_project_date_day
        } else {
          ganttrify::test_project_date_month 
        }
      } else {
        ganttrify::test_project
      }
      
    } else if (input$source_type=="csv") {
      req(input$project_file)
      readr::read_csv(file = input$project_file$datapath)
    } else if (input$source_type=="googledrive") {
      googlesheets4::gs4_deauth()
      googlesheets4::read_sheet(ss = input$googledrive_link,
                                sheet = 1,
                                col_names = TRUE,
                                col_types = "c")
    }
  }, ignoreNULL = FALSE)
  
  current_spots_df <- shiny::eventReactive({
    input$go
    input$by_date_radio
    input$precision_radio
  }, {
    if (input$source_type=="demo") {
      
      if (input$by_date_radio=="By date") {
        if (input$precision_radio=="Day") {
          ganttrify::test_spots_date_day
        } else {
          ganttrify::test_spots_date_month
        }
      } else {
        ganttrify::test_spots
      }
      
    } else if (input$source_type=="csv") {
      req(input$spot_file)
      readr::read_csv(file = input$spot_file$datapath)
    } else if (input$source_type=="googledrive") {
      googlesheets4::gs4_deauth()
      googlesheets4::read_sheet(ss = input$googledrive_link,
                                sheet = 2,
                                col_names = TRUE,
                                col_types = "c")
    }
  }, ignoreNULL = FALSE)

  output$current_project_table <- renderTable(
    if (input$go==0) {
      ganttrify::test_project
    } else if (is.null(current_project_df())==FALSE) {
      current_project_df()
    },
    striped = TRUE,
    hover = TRUE, 
    digits = 0,
    align = "c",
    width = "100%")
  
  
  
  output$current_spots_table <- renderTable(
    if (input$go==0) {
      ganttrify::test_spots
    } else if (is.null(current_spots_df())==FALSE) {
      current_spots_df()
    },
    striped = TRUE,
    hover = TRUE,
    digits = 0,
    align = "c",
    width = "100%"
  )

  gantt_chart <- shiny::reactive({
      ganttrify::ganttrify(project = current_project_df(),
                           project_start_date = input$start_date,
                           spots = current_spots_df(),
                           by_date = ifelse(input$by_date_radio=="By date", TRUE, FALSE),
                           exact_date = ifelse(input$precision_radio=="Day", ifelse(input$by_date_radio=="By date", TRUE, FALSE), FALSE),
                           mark_quarters = input$mark_quarters,
                           month_number = input$month_number,
                           size_wp = input$size_wp,
                           size_activity = input$size_activity,
                           size_text_relative = input$size_text_relative/100,
                           colour_palette = unlist(ifelse(test = input$custom_palette_check, strsplit(input$custom_palette_text, split = ","), list(as.character(wesanderson::wes_palette(input$wes_palette))))))
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