ui <- fluidPage(
  tags$link(rel = "stylesheet", type = "text/css", href = "css/roboto.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "css/satisfy.css"),
  tags$style("body {font-family: 'Roboto', sans-serif;}"),
  tags$style("h2 {font-family: 'Satisfy', sans-serif;
  font-size: 50px;
  text-align: center;
  color: #6f2c91;
  text-shadow: 3px 3px 3px #grey; 
  text-decoration: none;}"),
  tags$style("h2 a {text-align:center;
  font-size: 50px;
  text-align: center;
  color: #6f2c91;
  text-shadow: 3px 3px 3px #grey;}"),
  tags$style("h2 a:hover {text-align:center;
  font-size: 50px;
  text-align: center;
  color: #a6ce39;
  text-shadow: 3px 3px 3px #grey;}"),
  tags$style("h3 a {font-family: 'Satisfy', sans-serif; fonts-size: 30px; text-align: center; color: #6f2c91; text-shadow: 3px 3px 3px #grey;"),
  tags$style("h3 a:hover {font-family: 'Satisfy', sans-serif; fonts-size: 30px; text-align: center; color: #a6ce39; text-shadow: 3px 3px 3px #grey;"),
  tags$style("h3 {font-family: 'Satisfy', sans-serif; fonts-size: 30px; text-align: center; color: #a6ce39; text-shadow: 3px 3px 3px #grey;"),
  tags$style("h4 {font-family: 'Roboto', sans-serif; font-weight: bold; text-shadow: 3px 3px 3px #grey;text-decoration: underline; text-align: center;"),
  tags$style("h4 a {font-family: 'Roboto', sans-serif; font-weight: bold; text-shadow: 3px 3px 3px #grey;text-decoration: underline; text-align: center; color: #6f2c91;"),
  tags$style("h4 a:hover {font-family: 'Roboto', sans-serif; font-weight: bold; text-shadow: 3px 3px 3px #grey;text-decoration: underline; text-align: center; color: #a6ce39;"),
  tags$style(".col-sm-8 {text-align: center;}"),
  tags$style(".col-sm-8 table {text-align: center;}"),
  tags$style("#current_project_table {width:95%;text-align: center;}"),
  tags$style("#current_spots_table {width:95%;text-align: center;}"),
  
  
  shiny::titlePanel(title = tags$a("Ganttrify!", href='https://github.com/giocomai/ganttrify/'),
                    windowTitle = "Ganttrify - A tool by EDJNet"),

  sidebarLayout(
    sidebarPanel(
      shiny::radioButtons(inputId = "source_type",
                          label = "Source for project information",
                          choices = c(demo = "demo",
                                      `CSV files` = "csv",
                                      `Microsoft Excel spreadsheet` = "xlsx",
                                      `Google spreadsheet` = "googledrive")),
      
      conditionalPanel(
        condition = "input.source_type == 'csv'",
        shiny::fileInput(inputId = "project_file", label = "Upload csv of project"),
        shiny::fileInput(inputId = "spot_file", label = "Upload csv of spots")),
      conditionalPanel(
        condition = "input.source_type == 'xlsx'",
        shiny::fileInput(inputId = "project_file_xlsx", label = "Upload xlsx of project"),
        shiny::helpText("Put your project in the first sheet, and your spot events in the second sheet of the same file")),
      conditionalPanel(
        condition = "input.source_type == 'googledrive'",
        shiny::textInput(inputId = "googledrive_link",
                         label = "Link to Google Drive spreadsheet",
                         value = "https://docs.google.com/spreadsheets/d/1fgrsCqtGaV5sd_fD48VwBLWCANEvyV-Di7RTKC6Yo7o/"),
        shiny::helpText("Note: the Google Drive spreadsheet must be visibile by anyone with the link; to have a properly structured spreadsheet, the easiest way is to copy the example document: 'File' -> 'Create a copy'")
        ),
   
      
      shiny::textInput(inputId = "start_date", label = "Starting date of the project", value = substring(text = as.character(Sys.Date()), first = 1, last = 7)),
      shiny::radioButtons(inputId = "by_date_radio", label = "Input timing format", choices = c("By project month number", "By date")),
      conditionalPanel(
        condition = "input.by_date_radio == 'By date'",
        shiny::radioButtons(inputId = "precision_radio", label = "Precision of the timeline", choices = c("Month", "Day"))),
      shiny::checkboxInput(inputId = "customisation_check", label = "Show additional customisation options", value = FALSE),
      conditionalPanel(
        condition = "input.customisation_check == true",
        shiny::radioButtons(inputId = "text_alignment", label = "Text alignment", choices = c("left", "right"), selected = "right", inline = TRUE),
      shiny::checkboxInput(inputId = "month_number", label = "Include month numbers on top", value = TRUE),
      shiny::checkboxInput(inputId = "mark_quarters", label = "Add vertical lines to mark quarters", value = TRUE),
      shiny::sliderInput(inputId = "size_wp", label = "Thickness of the line for working packages", min = 1, max = 10, value = 6, step = 1, round = TRUE),
      shiny::sliderInput(inputId = "size_activity", label = "Thickness of the line for activities", min = 1, max = 10, value = 4, step = 1, round = TRUE),
      shiny::sliderInput(inputId = "size_text_relative", label = "Relative size of all text", value = 120, min = 50, max = 250, round = TRUE, post = "%"),
      shiny::selectInput(inputId = "wes_palette", label = "Pick colour palette", choices = names(wesanderson::wes_palettes), selected = "Darjeeling1", multiple = FALSE),
      shiny::checkboxInput(inputId = "custom_palette_check", label = "Custom colour palette?", value = FALSE),
      conditionalPanel(
        condition = "input.custom_palette_check == true",
        shiny::textInput(inputId = "custom_palette_text", label = "Custom hex values", value = "#a6ce39,#6f2c91,#a6ce39"),
        shiny::helpText("Insert comma-separated hex values, with no spaces."))),
      shiny::HTML("<hr />"),
      shiny::h3(tags$a("A tool by EDJNet", href='https://www.europeandatajournalism.eu/')),
      shiny::h3(tags$a(tags$img(src = "img/edjnet_logo_full.svg"), href='https://www.europeandatajournalism.eu/'))
    ),
    mainPanel(
      shiny::actionButton("go", "Update chart"),
      shiny::plotOutput(outputId = "gantt"),
      shiny::downloadButton(outputId = "download_gantt_png",
                            label =  "Download chart as image (png)"),
      shiny::downloadButton(outputId = "download_gantt_pdf",
                            label =  "Download chart in pdf"),
      shiny::downloadButton(outputId = "download_gantt_svg",
                            label =  "Download chart in svg"),
      shiny::actionButton(inputId = "a4_button", label = "Set download size to horizontal A4"),
      helpText("ⓘ - As the preview above adapts to your screen, the image preview will not match the one you download. Nothing stops you from downloading the preview image if you like it that way."), 
      div(style="display: inline-block; vertical-align:top; width: 200px;",
          shiny::numericInput(inputId = "download_width",
                              label = "Download width (in cm)",
                              value = 18,
                              min = 1)),
      div(style="display: inline-block; vertical-align:top; width: 30px;",HTML("<br>")),
      div(style="display: inline-block; vertical-align:top; width: 200px;",
          shiny::numericInput(inputId = "download_height",
                              label = "Download height (in cm)",
                              value = 9,
                              min = 1)),
      shiny::hr(),
      shiny::h4("Project data"), 
      shiny::tableOutput(outputId = "current_project_table"),
      shiny::h4("Spot occurrences"), 
      shiny::tableOutput(outputId = "current_spots_table"),
      shiny::h4(tags$a("Source code and documentation available on GitHub", href='https://github.com/giocomai/ganttrify')),
      shiny::h4(tags$a("Developed by Giorgio Comai", href='https://giorgiocomai.eu/')),

    )
  )
  
)
