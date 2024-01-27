#' Create a Gantt chart based on a valid `ganttrify` project
#' 
#' Pre-processed or customised inputs welcome.
#'
#' @inheritParams gantt_sequencify
#'
#' @return A ggplot2 object, a nice-looking Gantt chart.
#' @export
#'
#' @examples
#' gantt_plotify(project = ganttrify::test_project)
gantt_plotify <- function(project = NULL, 
                          projectified = NULL,
                          ...) {
  
  if (is.null(projectified)) {
    if (is.null(project)) {
      cli::cli_abort(message = c(x = "Either {.arg project} or {.arg projectified} must not be {.code NULL}"))
    }
    projectified <- gantt_projectify(project = project,
                                        ...)
  }
  
  gg_gantt <- ggplot2::ggplot(
    data = projectified,
    mapping = ggplot2::aes(
      x = start_date,
      y = activity,
      xend = end_date,
      yend = activity,
      colour = wp
    )
  ) +
    # background shaded bands
    ggplot2::geom_rect(
      data = date_range_df,
      ggplot2::aes(
        xmin = start,
        xmax = end,
        ymin = -Inf,
        ymax = Inf
      ),
      inherit.aes = FALSE,
      alpha = 0.4,
      fill = colour_stripe
    )
  
  if (mark_quarters == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::geom_vline(xintercept = date_breaks_q, colour = "gray50")
  }
  
  if (mark_years == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::geom_vline(xintercept = date_breaks_y, colour = "gray50")
  }
  
  # set alpha to 0 for wp
  projectified$wp_alpha <- 0
  projectified$activity_alpha <- 0
  projectified <- projectified %>%
    dplyr::mutate(activity_alpha = ifelse(type == "activity", alpha_activity, 0))
  projectified <- projectified %>%
    dplyr::mutate(wp_alpha = ifelse(type == "wp", alpha_wp, 0))
  
  if (utils::packageVersion("ggplot2") > "3.3.6") {
    gg_gantt <- gg_gantt +
      ### activities
      ggplot2::geom_segment(
        data = projectified,
        lineend = line_end_activity,
        linewidth = size_activity,
        alpha = projectified$activity_alpha
      ) +
      ### wp
      ggplot2::geom_segment(
        data = projectified,
        lineend = line_end_wp,
        linewidth = size_wp,
        alpha = projectified$wp_alpha
      )
  } else {
    gg_gantt <- gg_gantt +
      ### activities
      ggplot2::geom_segment(
        data = projectified,
        lineend = line_end_activity,
        size = size_activity,
        alpha = projectified$activity_alpha
      ) +
      ### wp
      ggplot2::geom_segment(
        data = projectified,
        lineend = line_end_wp,
        size = size_wp,
        alpha = projectified$wp_alpha
      )
  }
  
  if (month_number_label == TRUE & month_date_label == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(
        name = NULL,
        breaks = date_breaks,
        date_labels = "%b\n%Y",
        minor_breaks = NULL,
        sec.axis = ggplot2::dup_axis(labels = paste0(month_label_string, seq_along(date_breaks) * month_breaks - (month_breaks - 1)))
      )
  } else if (month_number_label == FALSE & month_date_label == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(
        name = NULL,
        breaks = date_breaks,
        date_labels = "%b\n%Y",
        minor_breaks = NULL,
        position = x_axis_position
      )
  } else if (month_number_label == TRUE & month_date_label == FALSE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(
        name = NULL,
        breaks = date_breaks,
        date_labels = paste0(month_label_string, seq_along(date_breaks) * month_breaks - (month_breaks - 1)),
        minor_breaks = NULL,
        position = x_axis_position
      )
  } else if (month_number_label == FALSE & month_date_label == FALSE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(name = NULL)
  }
  
  if (axis_text_align == "right") {
    axis_text_align_n <- 1
  } else if (axis_text_align == "centre" | axis_text_align == "center") {
    axis_text_align_n <- 0.5
  } else if (axis_text_align == "left") {
    axis_text_align_n <- 0
  } else {
    axis_text_align_n <- 1
  }
  
  gg_gantt <- gg_gantt +
    ggplot2::scale_y_discrete(
      name = NULL,
      breaks = level_labels_df$levels,
      labels = level_labels_df$labels
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_colour_manual(values = colour_palette) +
    ggplot2::theme(
      text = ggplot2::element_text(family = font_family),
      axis.text.y.left = ggtext::element_markdown(
        size = ggplot2::rel(size_text_relative),
        hjust = axis_text_align_n
      ),
      axis.text.x = ggplot2::element_text(size = ggplot2::rel(size_text_relative)),
      legend.position = "none"
    )
  
  if (is.null(spots) == FALSE) {
    if (is.data.frame(spots) == TRUE) {
      spots_df <- spots %>%
        tidyr::drop_na() %>%
        dplyr::left_join(
          y = level_labels_df %>%
            dplyr::rename(activity = labels),
          by = "activity"
        ) %>%
        dplyr::mutate(activity = levels) %>%
        dplyr::select(-"levels")
      
      if (by_date == FALSE) {
        spots_date <- spots_df %>%
          dplyr::mutate(
            spot_date = as.numeric(spot_date),
            activity = as.character(activity),
            spot_type = as.character(spot_type)
          ) %>%
          dplyr::mutate(
            activity = factor(x = activity, levels = level_labels_df$levels),
            spot_date = zoo::as.Date(start_yearmon + (1 / 12) * zoo::as.yearmon(spot_date), frac = 0.5),
            end_date = as.Date(NA),
            wp = NA
          )
      } else {
        if (exact_date == TRUE) {
          spots_date <- spots_df %>%
            dplyr::mutate(
              activity = factor(x = activity, levels = level_labels_df$levels),
              spot_date = as.Date(spot_date),
              end_date = as.Date(NA),
              wp = NA
            )
        } else {
          spots_date <- spots_df %>%
            dplyr::mutate(
              activity = factor(x = activity, levels = level_labels_df$levels),
              spot_date = zoo::as.Date(zoo::as.yearmon(spot_date), frac = 0.5),
              end_date = as.Date(NA),
              wp = NA
            )
        }
      }
      
      gg_gantt <- gg_gantt +
        ggplot2::geom_label(
          data = spots_date,
          mapping = ggplot2::aes(
            x = spot_date,
            y = activity,
            label = spot_type
          ),
          label.padding = spot_padding,
          label.size = spot_border,
          colour = spot_text_colour,
          fontface = spot_fontface,
          family = font_family,
          size = 3 * size_text_relative * spot_size_text_relative,
          fill = spot_fill
        )
    }
  }
  
  if (show_vertical_lines == FALSE) {
    if (utils::packageVersion("ggplot2") > "3.3.6") {
      gg_gantt <- gg_gantt +
        ggplot2::theme(panel.grid.major.x = ggplot2::element_line(linewidth = 0))
    } else {
      gg_gantt <- gg_gantt +
        ggplot2::theme(panel.grid.major.x = ggplot2::element_line(size = 0))
    }
  }
  
  gg_gantt
}
