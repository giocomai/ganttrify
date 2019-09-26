#' Create Gantt charts from a data frame
#'
#' Creates Gantt charts with ggplot2.
#'
#' @param df A data frame.
#' @param start_date The date when the project starts. It can be a date, or a string in the format "2020-03" or "2020-03-01".
#' @param colour_palette A character vector of colours or a colour palette.
#' @param size_text_relative Numeric, defaults to 1. Changes the size of all textual elements relative to their default size. If you set this to e.g. 1.5 all text elements will be 50\% bigger.
#'
#' @return A processed data frame ready to be turned into a Gantt chart.
#'
#' @examples
#' ganttrify(ganttrify::test_project)
#'
#' @export
#'

ganttrify <- function(df,
                      spots = NULL,
                      start_date = Sys.Date(),
                      colour_palette = wesanderson::wes_palette("Darjeeling1"),
                      font_family = "Roboto Condensed",
                      mark_quarters = FALSE,
                      month_number = TRUE, 
                      size_wp = 6, 
                      size_activity = 4,
                      size_text_relative = 1) {
  
  start_yearmon <- zoo::as.yearmon(start_date)-(1/12)
  
  df_yearmon <- df %>%
    dplyr::mutate(start_month_yearmon = start_yearmon+(1/12)*start_month,
                  end_month_yearmon = start_yearmon+(1/12)*zoo::as.yearmon(end_month)) %>%
    dplyr::transmute(wp,
                     activity,
                     start_date = zoo::as.Date(start_month_yearmon, frac = 0),
                     end_date = zoo::as.Date(end_month_yearmon, frac = 1))
  
  date_range_matrix <- matrix(as.numeric(seq.Date(from = min(df_yearmon[["start_date"]]),
                                                  to = max(df_yearmon[["end_date"]]),
                                                  by = "1 month")),
                              ncol = 2,
                              byrow = TRUE)
  
  date_range_df <- tibble::tibble(start = zoo::as.Date.numeric(date_range_matrix[,1]),
                                  end = zoo::as.Date.numeric(date_range_matrix[,2]))
  
  # date breaks in the middle of the month
  date_breaks <- zoo::as.Date(zoo::as.yearmon(seq.Date(from = min(df_yearmon[["start_date"]]+15),
                                                       to = max(df_yearmon[["end_date"]]+15),
                                                       by = "1 month")), frac = 0.5)
  
  date_breaks_q <- seq.Date(from = lubridate::floor_date(x = min(df_yearmon[["start_date"]]), unit = "year"),
                            to = lubridate::ceiling_date(x = max(df_yearmon[["end_date"]]), unit = "year"),
                            by = "1 quarter")
  
  df_levels <- rev(df_yearmon %>%
                     dplyr::select(wp, activity) %>%
                     t() %>%
                     as.character() %>%
                     unique())
  
  df_yearmon_fct <-
    dplyr::bind_rows(activity = df_yearmon,
                     wp = df_yearmon %>%
                       dplyr::group_by(wp) %>%
                       dplyr::summarise(activity = unique(wp), start_date = min(start_date), end_date = max(end_date)), .id = "type") %>%
    dplyr::mutate(activity = factor(x = activity, levels = df_levels)) %>%
    dplyr::arrange(activity)
  
  gg_gantt <- ggplot2::ggplot(data = df_yearmon_fct,
                              mapping = ggplot2::aes(x = start_date,
                                                     y = activity,
                                                     xend = end_date,
                                                     yend = activity,
                                                     colour = wp)) +
    # background shaded bands
    ggplot2::geom_rect(data = date_range_df, ggplot2::aes(xmin = start,
                                                          xmax = end,
                                                          ymin = -Inf,
                                                          ymax = Inf),
                       inherit.aes=FALSE,
                       alpha = 0.4,
                       fill = c("lightgray")) 
  
  if (mark_quarters == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::geom_vline(xintercept = date_breaks_q, colour = "gray50")
  }
  
  gg_gantt <- gg_gantt +
    ### activities
    ggplot2::geom_segment(data = df_yearmon_fct,
                          lineend = "round",
                          size = size_activity) +
    ### wp
    ggplot2::geom_segment(data = df_yearmon_fct %>%
                            dplyr::filter(type=="wp"),
                          lineend = "round",
                          size = size_wp) 
  
  if (month_number==TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(name = "",
                            breaks = date_breaks,
                            date_labels = "%b\n%Y",
                            minor_breaks = NULL,
                            sec.axis = ggplot2::dup_axis(labels = paste0("M", seq_along(date_breaks))))
  } else {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(name = "",
                            breaks = date_breaks,
                            date_labels = "%b\n%Y",
                            minor_breaks = NULL)
  }
  gg_gantt <- gg_gantt +
    ggplot2::scale_y_discrete("") +
    ggplot2::theme_minimal() +
    ggplot2::scale_colour_manual(values = colour_palette) +
    ggplot2::theme(text = ggplot2::element_text(family = font_family),
                   axis.text.y.left = ggplot2::element_text(face = ifelse(test = df_yearmon_fct %>%
                                                                            dplyr::distinct(activity, wp, type) %>%
                                                                            dplyr::pull(type)=="wp", yes = "bold", no = "plain"),
                                                            size = ggplot2::rel(size_text_relative)),
                   axis.text.x = ggplot2::element_text(size = ggplot2::rel(size_text_relative)),
                   legend.position = "none")
  if (is.null(spots)==FALSE) {
    spots_date <- spots %>% 
      dplyr::mutate(activity = factor(x = activity, levels = df_levels), 
                    spot_date = zoo::as.Date(start_yearmon+(1/12)*zoo::as.yearmon(spot_date), frac = 0.5), 
                    end_date = as.Date(NA), 
                    wp = NA)
    
    gg_gantt <- gg_gantt +
      ggplot2::geom_label(data = spots_date, 
                          mapping = ggplot2::aes(x = spot_date,
                                                 y = activity,
                                                 label = spot_type),
                          colour = "gray30",
                          fontface = "bold",
                          family = font_family,
                          size = 3*size_text_relative) 
  } 
  
  return(gg_gantt)
  
}

