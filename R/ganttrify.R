#' Create Gantt charts from a data frame
#'
#' Creates Gantt charts with ggplot2.
#'
#' @param project A data frame. See `ganttrify::test_project` for an example.
#' @param spots A data frame. See `ganttrify::test_spots` for an example.
#' @param by_date Logical, defaults to FALSE If FALSE, the the start and end columns in the data frame should correspond to month numbers from the beginning of the project. If TRUE, dates in the format ("2020-10" or "2020-10-01") should be given.
#' @param exact_date Logical, defaults to FALSE. If FALSE, then periods are always understood to include full months. If FALSE, then exact dates can be given.
#' @param project_start_date The date when the project starts. It can be a date, or a string in the format "2020-03" or "2020-03-01". Ignored if `month_number` is set to FALSE.
#' @param colour_palette A character vector of colours or a colour palette.
#' @param font_family A character vector of length 1, defaults to "sans". It is recommended to use a narrow/condensed font such as Roboto Condensed for more efficient use of text space.
#' @param mark_quarters Logical, defaults to FALSE. If TRUE, vertical lines are added in correspondence of change of quarter (end of March, end of June, end of September, end of December).
#' @param mark_years Logical, defaults to FALSE. If TRUE, vertical lines are added in correspondence of change of year (1 January).
#' @param size_wp Numeric, defaults to 6. It defines the thickness of the line used to represent WPs.
#' @param size_activity Numeric, defaults to 4. It defines the thickness of the line used to represent activities.
#' @param size_text_relative Numeric, defaults to 1. Changes the size of all textual elements relative to their default size. If you set this to e.g. 1.5 all text elements will be 50\% bigger.
#' @param month_number Logical, defaults to TRUE. If TRUE, it included month numbering on top of the chart.
#' @param colour_stripe Character, defaults to "lightgray". This is the stripe colour in the background used in alternate months.
#'
#' @return A processed data frame ready to be turned into a Gantt chart.
#'
#' @examples
#' ganttrify(ganttrify::test_project)
#'
#' @export
#'

ganttrify <- function(project,
                      spots = NULL,
                      by_date = FALSE,
                      exact_date = FALSE, 
                      project_start_date = Sys.Date(),
                      colour_palette = wesanderson::wes_palette("Darjeeling1"),
                      font_family = "sans",
                      mark_quarters = FALSE,
                      mark_years = FALSE,
                      size_wp = 6, 
                      size_activity = 4,
                      size_text_relative = 1,
                      month_number = TRUE,
                      colour_stripe = "lightgray") {
  
  # repeat colours if not enough colours given
  if (length(unique(project$wp))>length(as.character(wesanderson::wes_palette("Darjeeling1")))) {
    colour_palette <- rep(colour_palette, length(unique(project$wp)))[1:length(unique(project$wp))]
  }
  
  if (by_date==FALSE) {
    df <- project %>% 
      dplyr::mutate(start_date = as.numeric(start_date),
                    end_date = as.numeric(end_date))
    
    if (sum(is.na(df$start_date))==nrow(df)) {
      stop("Make sure that the input data are properly formatted and/or you have selected the right paramaters.")
    }
    
    start_yearmon <- zoo::as.yearmon(project_start_date)-(1/12)
    
    df_yearmon <- df %>%
      dplyr::mutate(start_date_yearmon = start_yearmon+(1/12)*start_date,
                    end_date_yearmon = start_yearmon+(1/12)*zoo::as.yearmon(end_date)) %>%
      dplyr::transmute(wp = as.character(wp),
                       activity = as.character(activity),
                       start_date = zoo::as.Date(start_date_yearmon, frac = 0),
                       end_date = zoo::as.Date(end_date_yearmon, frac = 1))
  } else {
    if (exact_date==TRUE) {
      #do nothing
    } else {
      df_yearmon <- project %>% 
        dplyr::mutate(start_date_yearmon = zoo::as.yearmon(start_date),
                      end_date_yearmon = zoo::as.yearmon(end_date)) %>% 
        dplyr::transmute(wp = as.character(wp),
                         activity = as.character(activity),
                         start_date = zoo::as.Date(start_date_yearmon, frac = 0),
                         end_date = zoo::as.Date(end_date_yearmon, frac = 1))
    }
  }
  
  if (exact_date==TRUE) {
    df <-  project %>% 
      dplyr::mutate(start_date = as.Date(start_date),
                    end_date = as.Date(end_date),
                    wp = as.character(wp),
                    activity = as.character(activity))
    
    df_yearmon <- df %>% 
      dplyr::mutate(start_date = zoo::as.Date(zoo::as.yearmon(start_date), frac = 0),
                    end_date = zoo::as.Date(zoo::as.yearmon(end_date), frac = 1))
  } 

  
  sequence_months <- seq.Date(from = min(df_yearmon[["start_date"]]),
                              to = max(df_yearmon[["end_date"]]),
                              by = "1 month")
  
  if (length(sequence_months) %% 2 != 0) {
    sequence_months <- seq.Date(from = min(df_yearmon[["start_date"]]),
                                to = max(df_yearmon[["end_date"]])+1,
                                by = "1 month")
  }
  
  date_range_matrix <- matrix(as.numeric(sequence_months),
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
  
  date_breaks_y <- seq.Date(from = lubridate::floor_date(x = min(df_yearmon[["start_date"]]), unit = "year"),
                            to = lubridate::ceiling_date(x = max(df_yearmon[["end_date"]]), unit = "year"),
                            by = "1 year")
  
  df_levels <- rev(df_yearmon %>%
                     dplyr::select(wp, activity) %>%
                     t() %>%
                     as.character() %>%
                     unique())
  if (exact_date==TRUE) {
    df_yearmon_fct <-
      dplyr::bind_rows(activity = df,
                       wp = df %>%
                         dplyr::group_by(wp) %>%
                         dplyr::summarise(activity = unique(wp), start_date = min(start_date), end_date = max(end_date)), .id = "type") %>%
      dplyr::mutate(activity = factor(x = activity, levels = df_levels)) %>%
      dplyr::arrange(activity)
    
  } else {
    df_yearmon_fct <-
      dplyr::bind_rows(activity = df_yearmon,
                       wp = df_yearmon %>%
                         dplyr::group_by(wp) %>%
                         dplyr::summarise(activity = unique(wp), start_date = min(start_date), end_date = max(end_date)), .id = "type") %>%
      dplyr::mutate(activity = factor(x = activity, levels = df_levels)) %>%
      dplyr::arrange(activity)
  }
  
  
  
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
                       fill = colour_stripe) 
  
  if (mark_quarters == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::geom_vline(xintercept = date_breaks_q, colour = "gray50")
  }
  
  if (mark_years == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::geom_vline(xintercept = date_breaks_y, colour = "gray50")
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
  
  gg_gantt <- suppressWarnings(gg_gantt +
    ggplot2::scale_y_discrete("") +
    ggplot2::theme_minimal() +
    ggplot2::scale_colour_manual(values = colour_palette) +
    ggplot2::theme(text = ggplot2::element_text(family = font_family),
                   axis.text.y.left = ggplot2::element_text(face = ifelse(test = df_yearmon_fct %>%
                                                                            dplyr::distinct(activity, wp, type) %>%
                                                                            dplyr::pull(type)=="wp", yes = "bold", no = "plain"),
                                                            size = ggplot2::rel(size_text_relative)),
                   axis.text.x = ggplot2::element_text(size = ggplot2::rel(size_text_relative)),
                   legend.position = "none"))
  if (is.null(spots)==FALSE) {
    if (is.data.frame(spots)==TRUE) {
      if (by_date==FALSE) {
        spots_date <- spots %>% 
          tidyr::drop_na() %>% 
          dplyr::mutate(spot_date = as.numeric(spot_date), 
                        activity = as.character(activity),
                        spot_type = as.character(spot_type)) %>% 
          dplyr::mutate(activity = factor(x = activity, levels = df_levels), 
                        spot_date = zoo::as.Date(start_yearmon+(1/12)*zoo::as.yearmon(spot_date), frac = 0.5), 
                        end_date = as.Date(NA), 
                        wp = NA)
      } else {
        if (exact_date==TRUE) {
          spots_date <- spots %>% 
            tidyr::drop_na() %>% 
            dplyr::mutate(activity = as.character(activity)) %>% 
            dplyr::mutate(activity = factor(x = activity, levels = df_levels), 
                          spot_date = as.Date(spot_date), 
                          end_date = as.Date(NA), 
                          wp = NA)
        } else {
          spots_date <- spots %>% 
            tidyr::drop_na() %>% 
            dplyr::mutate(activity = factor(x = activity, levels = df_levels), 
                          spot_date = zoo::as.Date(zoo::as.yearmon(spot_date), frac = 0.5), 
                          end_date = as.Date(NA), 
                          wp = NA)
        }
      }

      
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
  } 
  
  return(gg_gantt)
  
}

