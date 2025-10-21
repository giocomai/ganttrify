#' Create Gantt charts from a data frame
#'
#' Creates Gantt charts with ggplot2.
#'
#' @param project A data frame. See `ganttrify::test_project` for an example.
#' @param spots A data frame. See `ganttrify::test_spots` for an example.
#' @param by_date Logical, defaults to FALSE If FALSE, the the start and end
#'   columns in the data frame should correspond to month numbers from the
#'   beginning of the project. If TRUE, dates in the format ("2020-10" or
#'   "2020-10-01") should be given.
#' @param exact_date Logical, defaults to FALSE. If FALSE, then periods are
#'   always understood to include full months. If FALSE, then exact dates can be
#'   given.
#' @param project_start_date The date when the project starts. It can be a date,
#'   or a string in the format "2020-03" or "2020-03-01". Ignored if
#'   `month_number_date` is set to FALSE.
#' @param colour_palette A character vector of colours or a colour palette. If
#'   necessary, colours are recycled as needed. Defaults to
#'   `wesanderson::wes_palette("Darjeeling1")`. For more palettes, consider also
#'   the `MetBrewer` package, e.g. `colour_palette =
#'   MetBrewer::met.brewer("Lakota")`. Colours can be passed as a vector of hex
#'   codes (e.g. `colour_palette = c("#6ACCEA", "#00FFB8", "#B90000",
#'   "#6C919C")`)
#' @param font_family A character vector of length 1, defaults to "sans". It is
#'   recommended to use a narrow/condensed font such as Roboto Condensed for
#'   more efficient use of text space.
#' @param mark_quarters Logical, defaults to FALSE. If TRUE, vertical lines are
#'   added in correspondence of change of quarter (end of March, end of June,
#'   end of September, end of December).
#' @param mark_years Logical, defaults to FALSE. If TRUE, vertical lines are
#'   added in correspondence of change of year (1 January).
#' @param size_wp Numeric, defaults to 6. It defines the thickness of the line
#'   used to represent WPs.
#' @param hide_wp Logical, defaults to FALSE. If TRUE, the lines of the WP are
#'   hidden and only activities are shown.
#' @param hide_activities Logical, defaults to FALSE. If TRUE, the lines of
#'   activities are hidden and only activities are shown.
#' @param wp_label_bold Logical, defaults to \code{TRUE}. If \code{TRUE}, the
#'   label for working packages is set to bold face, while activities remain
#'   plain. Set to \code{FALSE} to keep have all labels in plain face or for
#'   further customisation (`ganttrify` offers basic markdown support).
#' @param size_activity Numeric, defaults to 4. It defines the thickness of the
#'   line used to represent activities.
#' @param size_text_relative Numeric, defaults to 1. Changes the size of all
#'   textual elements relative to their default size. If you set this to e.g.
#'   1.5 all text elements will be 50\% bigger.
#' @param label_wrap Defaults to FALSE. If given, must be numeric, referring to
#'   the number of characters per line allowed in the labels of projects and
#'   activities, or logical (if set to TRUE, it will default to 32). To be used
#'   when labels would otherwise be excessively long.
#' @param month_number_label Logical, defaults to TRUE. If TRUE, it includes
#'   month numbering on x axis.
#' @param month_label_string Defaults to "M", relevant only if
#'   `month_number_label` is set to \code{TRUE}. String that precedes the month
#'   number: e.g. if set to "M", then months are labeled as "M1", "M2", etc.
#' @param month_date_label Logical, defaults to TRUE. If TRUE, it includes month
#'   names and dates on the x axis.
#' @param x_axis_position Logical, defaults to "top". Can also be "bottom". Used
#'   only when only one of `month_number_label` and `month_date_label` is TRUE,
#'   otherwise ignored.
#' @param colour_stripe Character, defaults to "lightgray". This is the stripe
#'   colour in the background used in alternate months.
#' @param alpha_wp Numeric, defaults to 1. Controls transparency of the line
#'   used to represent WPs.
#' @param alpha_activity Numeric, defaults to 1. Controls transparency of the
#'   line used to represent activities.
#' @param line_end Character, defaults to NULL. If given, takes precedence over
#'   `line_end_wp` and `line_end_activity` and applies the value to both. One of
#'   "round", "butt", "square". Controls line ends.
#' @param line_end_wp Character, defaults to "round". One of "round", "butt",
#'   "square". Controls line ends.
#' @param line_end_activity Character, defaults to "butt". One of "round",
#'   "butt", "square". Controls line ends.
#' @param spot_padding Unit, defaults to `ggplot2::unit(0.2, "lines")`. If you
#'   use spot events, this is the padding around the text. Smaller value are
#'   best for busy gantt charts; if you have lots of space or use larger font
#'   sizes you may want to increase this value.
#' @param spot_fontface Defaults to "bold". Available values are "plain",
#'   "bold", "italic" and "bold.italic".
#' @param spot_text_colour Defaults to "grey20", for a dark but not quite black
#'   text.
#' @param spot_size_text_relative Defaults to 1. This is combined with
#'   `size_text_relative`.
#' @param spot_fill Defaults to `ggplot2::alpha(c("white"), 1)`. This is the
#'   background fill colour of spot events. By default, it is set to solid
#'   white. If you want to add some transparency to enable visual continuity of
#'   the underlying lines, adjust the transparency value to your taste adapting
#'   the function used by default.
#' @param spot_border Defaults to 0.25. Internally passed as `label.size` to
#'   `geom_label()`.  Set to 0 or NA to remove the border.
#' @param month_breaks Numeric, defaults to 1. It defines if labels for all
#'   months are shown or only once every x months. Useful for longer projects.
#' @param show_vertical_lines Logical, defaults to TRUE. If set to FALSE, it
#'   hides the thin vertical lines corresponding to month numbers. Useful in
#'   particular for longer projects.
#' @param axis_text_align Character, defaults to "right". Defines alignment of
#'   text on the y-axis is left. Accepted values are "left", "right", "centre",
#'   or "center".
#'
#' @return A Gantt chart as a ggplot2 object.
#'
#' @examples
#' ganttrify(ganttrify::test_project)
#'
#' @export

ganttrify <- function(
  project,
  spots = NULL,
  by_date = FALSE,
  exact_date = FALSE,
  project_start_date = Sys.Date(),
  colour_palette = wesanderson::wes_palette("Darjeeling1"),
  font_family = "sans",
  mark_quarters = FALSE,
  mark_years = FALSE,
  size_wp = 6,
  hide_wp = FALSE,
  hide_activities = FALSE,
  wp_label_bold = TRUE,
  size_activity = 4,
  size_text_relative = 1,
  label_wrap = FALSE,
  month_number_label = TRUE,
  month_label_string = "M",
  month_date_label = TRUE,
  x_axis_position = "top",
  colour_stripe = "lightgray",
  alpha_wp = 1,
  alpha_activity = 1,
  line_end = NULL,
  line_end_wp = "round",
  line_end_activity = "butt",
  spot_padding = ggplot2::unit(0.2, "lines"),
  spot_fill = ggplot2::alpha(c("white"), 1),
  spot_text_colour = "gray20",
  spot_size_text_relative = 1,
  spot_fontface = "bold",
  spot_border = 0.25,
  month_breaks = 1,
  show_vertical_lines = TRUE,
  axis_text_align = "right"
) {
  project <- gantt_verify(
    project = project,
    by_date = by_date,
    exact_date = exact_date
  )

  # arguments consistency check
  if (hide_wp & hide_activities) {
    cli::cli_abort(
      "At least one of {.arg hide_wp} or {.arg hide_activities} must be {.code TRUE}, otherwise there's nothing left to show."
    )
  }

  # repeat colours if not enough colours given
  colour_palette <- rep(colour_palette, length(unique(project$wp)))[
    1:length(unique(project$wp))
  ]
  names(colour_palette) <- colour_palette

  if (is.null(line_end) == FALSE) {
    line_end_wp <- line_end
    line_end_activity <- line_end
  }

  if (by_date == FALSE) {
    df <- project %>%
      dplyr::mutate(
        start_date = as.numeric(start_date),
        end_date = as.numeric(end_date)
      )

    if (sum(is.na(df$start_date)) == nrow(df)) {
      stop(
        "Make sure that the input data are properly formatted and/or you have selected the right paramaters."
      )
    }

    start_yearmon <- zoo::as.yearmon(project_start_date) - (1 / 12)

    df_yearmon <- df %>%
      dplyr::mutate(
        start_date_yearmon = start_yearmon + (1 / 12) * start_date,
        end_date_yearmon = start_yearmon + (1 / 12) * zoo::as.yearmon(end_date)
      ) %>%
      dplyr::transmute(
        wp = as.character(wp),
        activity = as.character(activity),
        start_date = zoo::as.Date(start_date_yearmon, frac = 0),
        end_date = zoo::as.Date(end_date_yearmon, frac = 1)
      )
  } else {
    if (exact_date == TRUE) {
      # do nothing
    } else {
      df_yearmon <- project %>%
        dplyr::mutate(
          start_date_yearmon = zoo::as.yearmon(start_date),
          end_date_yearmon = zoo::as.yearmon(end_date)
        ) %>%
        dplyr::transmute(
          wp = as.character(wp),
          activity = as.character(activity),
          start_date = zoo::as.Date(start_date_yearmon, frac = 0),
          end_date = zoo::as.Date(end_date_yearmon, frac = 1)
        )
    }
  }

  if (exact_date == TRUE) {
    df <- project %>%
      dplyr::mutate(
        start_date = as.Date(start_date),
        end_date = as.Date(end_date),
        wp = as.character(wp),
        activity = as.character(activity)
      )

    df_yearmon <- df %>%
      dplyr::mutate(
        start_date = zoo::as.Date(zoo::as.yearmon(start_date), frac = 0),
        end_date = zoo::as.Date(zoo::as.yearmon(end_date), frac = 1)
      )
  }

  sequence_months <- seq.Date(
    from = min(df_yearmon[["start_date"]]),
    to = max(df_yearmon[["end_date"]]),
    by = "1 month"
  )

  if (length(sequence_months) %% 2 != 0) {
    sequence_months <- seq.Date(
      from = min(df_yearmon[["start_date"]]),
      to = max(df_yearmon[["end_date"]]) + 1,
      by = "1 month"
    )
  }

  date_range_matrix <- matrix(
    as.numeric(sequence_months),
    ncol = 2,
    byrow = TRUE
  )

  date_range_df <- tibble::tibble(
    start = zoo::as.Date.numeric(date_range_matrix[, 1]),
    end = zoo::as.Date.numeric(date_range_matrix[, 2])
  )

  # date breaks in the middle of the month
  date_breaks <- zoo::as.Date(
    zoo::as.yearmon(seq.Date(
      from = min(df_yearmon[["start_date"]] + 15),
      to = max(df_yearmon[["end_date"]] + 15),
      by = paste(month_breaks, "month")
    )),
    frac = 0.5
  )

  date_breaks_q <- seq.Date(
    from = lubridate::floor_date(
      x = min(df_yearmon[["start_date"]]),
      unit = "year"
    ),
    to = lubridate::ceiling_date(
      x = max(df_yearmon[["end_date"]]),
      unit = "year"
    ),
    by = "1 quarter"
  )

  date_breaks_q <- date_breaks_q[
    date_breaks_q >= min(df_yearmon[["start_date"]]) &
      date_breaks_q <= max(df_yearmon[["end_date"]])
  ]

  date_breaks_y <- seq.Date(
    from = lubridate::floor_date(
      x = min(df_yearmon[["start_date"]]),
      unit = "year"
    ),
    to = lubridate::ceiling_date(
      x = max(df_yearmon[["end_date"]]),
      unit = "year"
    ),
    by = "1 year"
  )

  date_breaks_y <- date_breaks_y[
    date_breaks_y >= min(df_yearmon[["start_date"]]) &
      date_breaks_y <= max(df_yearmon[["end_date"]])
  ]

  # deal with the possibility that activities in different WPs have the same name
  distinct_yearmon_levels_df <- df_yearmon %>%
    dplyr::distinct(wp, activity) %>%
    tidyr::unite(
      col = "wp_activity",
      wp,
      activity,
      remove = FALSE,
      sep = "_"
    ) %>%
    dplyr::group_by(wp) %>%
    dplyr::summarise(wp_activity = list(wp_activity)) %>%
    dplyr::left_join(
      x = tibble::tibble(wp = unique(df_yearmon[["wp"]])),
      by = "wp"
    ) %>%
    dplyr::group_by(wp) %>%
    dplyr::mutate(wp = stringr::str_c("wp", wp, wp, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(gantt_colour = colour_palette)

  distinct_colours_df <- dplyr::bind_rows(
    distinct_yearmon_levels_df %>%
      dplyr::transmute(
        activity = wp,
        gantt_colour = gantt_colour
      ),
    distinct_yearmon_levels_df %>%
      tidyr::unnest(wp_activity) %>%
      dplyr::transmute(
        activity = wp_activity,
        gantt_colour = gantt_colour
      )
  )

  distinct_yearmon_labels_df <- df_yearmon %>%
    dplyr::distinct(wp, activity) %>%
    dplyr::group_by(wp) %>%
    dplyr::summarise(activity = list(activity)) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(
      x = tibble::tibble(wp = unique(df_yearmon[["wp"]])),
      by = "wp"
    )

  if (wp_label_bold) {
    distinct_yearmon_labels_df <- distinct_yearmon_labels_df %>%
      dplyr::mutate(wp = stringr::str_c("<b>", wp, "</b>"))

    if (is.null(spots) == FALSE) {
      wp_v <- project %>%
        dplyr::distinct(wp) %>%
        dplyr::pull(wp)

      spots[["activity"]][spots[["activity"]] %in% wp_v] <- stringr::str_c(
        "<b>",
        spots[["activity"]][spots[["activity"]] %in% wp_v],
        "</b>"
      )
    }
  }

  level_labels_df <- tibble::tibble(
    levels = rev(unlist(t(matrix(
      c(distinct_yearmon_levels_df$wp, distinct_yearmon_levels_df$wp_activity),
      ncol = 2
    )))),
    labels = rev(unlist(t(matrix(
      c(distinct_yearmon_labels_df$wp, distinct_yearmon_labels_df$activity),
      ncol = 2
    ))))
  )

  if (label_wrap != FALSE) {
    if (isTRUE(label_wrap)) {
      label_wrap <- 32
    }

    level_labels_df$labels <- stringr::str_wrap(
      string = level_labels_df$labels,
      width = label_wrap
    )
    level_labels_df$labels <- stringr::str_replace_all(
      string = level_labels_df$labels,
      pattern = "\n",
      replacement = "<br />"
    )

    if (is.null(spots) == FALSE) {
      spots$activity <- stringr::str_wrap(
        string = spots$activity,
        width = label_wrap
      )
      spots$activity <- stringr::str_replace_all(
        string = spots$activity,
        pattern = "\n",
        replacement = "<br />"
      )
    }
  }

  if (exact_date == TRUE) {
    df_yearmon_fct <-
      dplyr::bind_rows(
        activity = df,
        wp = df %>%
          dplyr::group_by(wp) %>%
          dplyr::summarise(
            activity = unique(wp),
            start_date = min(start_date),
            end_date = max(end_date)
          ) %>%
          dplyr::mutate(wp = stringr::str_c("wp", wp, sep = "_")),
        .id = "type"
      ) %>%
      tidyr::unite(col = "activity", wp, activity, remove = FALSE) %>%
      dplyr::left_join(
        y = distinct_colours_df,
        by = "activity"
      ) %>%
      dplyr::mutate(
        activity = factor(x = activity, levels = level_labels_df$levels)
      ) %>%
      dplyr::arrange(activity)
  } else {
    df_yearmon_fct <-
      dplyr::bind_rows(
        activity = df_yearmon,
        wp = df_yearmon %>%
          dplyr::group_by(wp) %>%
          dplyr::summarise(
            activity = unique(wp),
            start_date = min(start_date),
            end_date = max(end_date)
          ) %>%
          dplyr::mutate(wp = stringr::str_c("wp", wp, sep = "_")),
        .id = "type"
      ) %>%
      tidyr::unite(col = "activity", wp, activity, remove = FALSE) %>%
      dplyr::left_join(
        y = distinct_colours_df,
        by = "activity"
      ) %>%
      dplyr::mutate(
        activity = factor(x = activity, levels = level_labels_df$levels)
      ) %>%
      dplyr::arrange(activity)
  }

  if (hide_wp == TRUE) {
    df_yearmon_fct <- df_yearmon_fct %>%
      dplyr::filter(type != "wp")
  }

  if (hide_activities == TRUE) {
    df_yearmon_fct <- df_yearmon_fct %>%
      dplyr::filter(type != "activity")
  }

  gg_gantt <- ggplot2::ggplot(
    data = df_yearmon_fct,
    mapping = ggplot2::aes(
      x = start_date,
      y = activity,
      xend = end_date,
      yend = activity,
      colour = gantt_colour
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
  df_yearmon_fct$wp_alpha <- 0
  df_yearmon_fct$activity_alpha <- 0
  df_yearmon_fct <- df_yearmon_fct %>%
    dplyr::mutate(
      activity_alpha = ifelse(type == "activity", alpha_activity, 0)
    )
  df_yearmon_fct <- df_yearmon_fct %>%
    dplyr::mutate(wp_alpha = ifelse(type == "wp", alpha_wp, 0))

  if (utils::packageVersion("ggplot2") > "3.3.6") {
    gg_gantt <- gg_gantt +
      ### activities
      ggplot2::geom_segment(
        data = df_yearmon_fct,
        lineend = line_end_activity,
        linewidth = size_activity,
        alpha = df_yearmon_fct$activity_alpha
      ) +
      ### wp
      ggplot2::geom_segment(
        data = df_yearmon_fct,
        lineend = line_end_wp,
        linewidth = size_wp,
        alpha = df_yearmon_fct$wp_alpha
      )
  } else {
    gg_gantt <- gg_gantt +
      ### activities
      ggplot2::geom_segment(
        data = df_yearmon_fct,
        lineend = line_end_activity,
        size = size_activity,
        alpha = df_yearmon_fct$activity_alpha
      ) +
      ### wp
      ggplot2::geom_segment(
        data = df_yearmon_fct,
        lineend = line_end_wp,
        size = size_wp,
        alpha = df_yearmon_fct$wp_alpha
      )
  }

  if (month_number_label == TRUE & month_date_label == TRUE) {
    gg_gantt <- gg_gantt +
      ggplot2::scale_x_date(
        name = NULL,
        breaks = date_breaks,
        date_labels = "%b\n%Y",
        minor_breaks = NULL,
        sec.axis = ggplot2::dup_axis(
          labels = paste0(
            month_label_string,
            seq_along(date_breaks) * month_breaks - (month_breaks - 1)
          )
        )
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
        labels = paste0(
          month_label_string,
          seq_along(date_breaks) * month_breaks - (month_breaks - 1)
        ),
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
      axis.text.x = ggplot2::element_text(
        size = ggplot2::rel(size_text_relative)
      ),
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
            spot_date = zoo::as.Date(
              start_yearmon + (1 / 12) * zoo::as.yearmon(spot_date),
              frac = 0.5
            ),
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
        ggplot2::theme(
          panel.grid.major.x = ggplot2::element_line(linewidth = 0)
        )
    } else {
      gg_gantt <- gg_gantt +
        ggplot2::theme(panel.grid.major.x = ggplot2::element_line(size = 0))
    }
  }

  return(gg_gantt)
}
