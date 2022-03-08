if (requireNamespace("extrafont", quietly = TRUE)) {
  library("extrafont", quietly = TRUE)
  extrafont::loadfonts(device = "pdf", quiet = TRUE)
  }

server <- function(input, output, session) {
  
  current_project_df <- shiny::eventReactive(
    {
      input$go
      input$by_date_radio
      input$precision_radio
      # input$googledrive_link
      # input$project_file
      # input$project_file_xlsx
      # input$spot_file
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
    } else if (input$source_type=="xlsx") {
      req(input$project_file_xlsx)
      readxl::read_excel(path = input$project_file_xlsx$datapath, sheet = 1)
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
    } else if (input$source_type=="xlsx") {
      req(input$project_file_xlsx)
      if (length(readxl::excel_sheets(input$project_file_xlsx$datapath))>1) {
        readxl::read_excel(path = input$project_file_xlsx$datapath, sheet = 2)  
      }
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
    gantt_gg <- ganttrify::ganttrify(project = current_project_df(),
                                     project_start_date = input$start_date,
                                     spots = if (length(current_spots_df())>0) {
                                       if (tibble::is_tibble(current_spots_df())&nrow(current_spots_df()>0)) {
                                         current_spots_df()}
                                       else {NULL}} else {NULL},
                                     by_date = ifelse(input$by_date_radio=="By date", TRUE, FALSE),
                                     exact_date = ifelse(input$precision_radio=="Day", ifelse(input$by_date_radio=="By date", TRUE, FALSE), FALSE),
                                     mark_quarters = input$mark_quarters,
                                     font_family = "Roboto Condensed",
                                     month_number = input$month_number,
                                     size_wp = input$size_wp,
                                     size_activity = input$size_activity,
                                     size_text_relative = input$size_text_relative/100,
                                     axis_text_align = input$text_alignment,
                                     colour_palette = unlist(ifelse(test = input$custom_palette_check, strsplit(input$custom_palette_text, split = ","), list(as.character(wesanderson::wes_palette(input$wes_palette))))))
    if (ggplot2::is.ggplot(gantt_gg)==FALSE) {
      warning("Please make sure that you have provided properly formatted data and selected the relevant option between 'By project month number' and 'By date'. Check the demo file for reference.")
    } else {
      gantt_gg
    }
  })
  
  output$gantt <- renderPlot({
    
    gantt_chart()
  })
  
  output$download_gantt_png <- downloadHandler(filename = "gantt.png",
                                           content = function(con) {
                                             ggplot2::ggsave(filename = con,
                                                             plot = gantt_chart(),
                                                             width = input$download_width,
                                                             height = input$download_height,
                                                             units = "cm",
                                                             type = "cairo",
                                                             bg = "white")
                                           }
  )
  
  output$download_gantt_pdf <- downloadHandler(filename = "gantt.pdf",
                                               content = function(con) {
                                                 ggplot2::ggsave(filename = con,
                                                                 plot = gantt_chart(),
                                                                 width = input$download_width,
                                                                 height = input$download_height,
                                                                 device = cairo_pdf,
                                                                 bg = "white",
                                                                 units = "cm")
                                               }
  )
  
  
  output$download_gantt_svg <- downloadHandler(filename = "gantt.svg",
                                               content = function(con) {
                                                 ggplot2::ggsave(filename = con,
                                                                 plot = gantt_chart(),
                                                                 width = input$download_width,
                                                                 height = input$download_height,
                                                                 units = "cm",
                                                                 bg = "white")
                                               }
  )
  
  shiny::observeEvent(eventExpr = input$a4_button, {
    shiny::updateNumericInput(inputId = "download_width", value = 29.7, session = session)
    shiny::updateNumericInput(inputId = "download_height", value = 21, session = session)
  })
}
