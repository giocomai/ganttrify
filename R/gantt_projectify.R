#' Process a `ganttrify` project and make it amenable to processing with ggplot2
#'
#' @inheritParams ganttrify
#'
#' @return A data frame, expected input for [gantt_plotify()].
#' @export
#'
#' @examples
#' gantt_projectify(project = ganttrify::test_project)
#' @importFrom rlang .data
gantt_projectify <- function(project,
                             by_date = FALSE,
                             exact_date = FALSE,
                             project_start_date = Sys.Date(),
                             colour_palette = wesanderson::wes_palette("Darjeeling1"),
                             size_wp = 6,
                             hide_wp = FALSE,
                             wp_label_bold = TRUE,
                             size_activity = 4,
                             hide_activity = FALSE,
                             label_wrap = FALSE,
                             alpha_wp = 1,
                             alpha_activity = 1,
                             line_end = NULL,
                             line_end_wp = "round",
                             line_end_activity = "butt",
                             month_breaks = 1) {
  if (is.null(attr(x = project, which = "ganttrify_status"))) {
    project <- gantt_verify(
      project = project,
      by_date = by_date,
      exact_date = exact_date
    )
  }

  # repeat colours if not enough colours given
  if (length(unique(project$wp)) > length(as.character(colour_palette))) {
    colour_palette <- rep(
      colour_palette,
      length(unique(project$wp))
    )[1:length(unique(project$wp))]
  }

  if (is.null(line_end) == FALSE) {
    line_end_wp <- line_end
    line_end_activity <- line_end
  }

  if (by_date == FALSE) {
    start_yearmon <- zoo::as.yearmon(project_start_date) - (1 / 12)

    df_yearmon <- project %>%
      dplyr::mutate(
        start_date_yearmon = start_yearmon + (1 / 12) * .data[["start_date"]],
        end_date_yearmon = start_yearmon + (1 / 12) * zoo::as.yearmon(.data[["end_date"]])
      ) %>%
      dplyr::transmute(
        wp = as.character(.data[["wp"]]),
        activity = as.character(.data[["activity"]]),
        start_date = zoo::as.Date(.data[["start_date_yearmon"]], frac = 0),
        end_date = zoo::as.Date(.data[["end_date_yearmon"]], frac = 1)
      )
  } else {
    if (exact_date) {
      df_yearmon <- project %>%
        dplyr::mutate(
          start_date = zoo::as.Date(zoo::as.yearmon(.data[["start_date"]]), frac = 0),
          end_date = zoo::as.Date(zoo::as.yearmon(.data[["en_date"]]), frac = 1)
        )
    } else {
      df_yearmon <- project %>%
        dplyr::mutate(
          start_date_yearmon = zoo::as.yearmon(.data[["start_date"]]),
          end_date_yearmon = zoo::as.yearmon(.data[["end_date"]])
        ) %>%
        dplyr::transmute(
          wp = as.character(.data[["wp"]]),
          activity = as.character(.data[["activity"]]),
          start_date = zoo::as.Date(.data[["start_date_yearmon"]], frac = 0),
          end_date = zoo::as.Date(.data[["end_date_yearmon"]], frac = 1)
        )
    }
  }

  # deal with the possibility that activities in different WPs have the same name
  distinct_yearmon_levels_df <- df_yearmon %>%
    dplyr::distinct(wp, activity) %>%
    tidyr::unite(col = "wp_activity", wp, activity, remove = FALSE, sep = "_") %>%
    dplyr::group_by(wp) %>%
    dplyr::summarise(wp_activity = list(wp_activity)) %>%
    dplyr::group_by(wp) %>%
    dplyr::mutate(wp = stringr::str_c(wp, wp, sep = "_")) %>%
    dplyr::ungroup()

  distinct_yearmon_labels_df <- df_yearmon %>%
    dplyr::distinct(wp, activity) %>%
    dplyr::group_by(wp) %>%
    dplyr::summarise(activity = list(activity)) %>%
    dplyr::ungroup()

  if (wp_label_bold) {
    distinct_yearmon_labels_df <- distinct_yearmon_labels_df %>%
      dplyr::mutate(wp = stringr::str_c("<b>", wp, "</b>"))

    # if (is.null(spots) == FALSE) {
    #   wp_v <- project %>%
    #     dplyr::distinct(wp) %>%
    #     dplyr::pull(wp)
    #
    #   spots[["activity"]][spots[["activity"]] %in% wp_v] <- stringr::str_c("<b>", spots[["activity"]][spots[["activity"]] %in% wp_v], "</b>")
    # }
  }

  level_labels_df <- tibble::tibble(
    levels = rev(unlist(t(matrix(c(distinct_yearmon_levels_df$wp, distinct_yearmon_levels_df$wp_activity), ncol = 2)))),
    labels = rev(unlist(t(matrix(c(distinct_yearmon_labels_df$wp, distinct_yearmon_labels_df$activity), ncol = 2))))
  )

  if (label_wrap != FALSE) {
    if (isTRUE(label_wrap)) {
      label_wrap <- 32
    }

    level_labels_df$labels <- stringr::str_wrap(string = level_labels_df$labels, width = label_wrap)
    level_labels_df$labels <- stringr::str_replace_all(string = level_labels_df$labels, pattern = "\n", replacement = "<br />")

    if (is.null(spots) == FALSE) {
      spots$activity <- stringr::str_wrap(string = spots$activity, width = label_wrap)
      spots$activity <- stringr::str_replace_all(string = spots$activity, pattern = "\n", replacement = "<br />")
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
          ),
        .id = "type"
      ) %>%
      tidyr::unite(col = "activity", wp, activity, remove = FALSE) %>%
      dplyr::mutate(activity = factor(x = activity, levels = level_labels_df$levels)) %>%
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
          ),
        .id = "type"
      ) %>%
      tidyr::unite(col = "activity", wp, activity, remove = FALSE) %>%
      dplyr::mutate(activity = factor(x = activity, levels = level_labels_df$levels)) %>%
      dplyr::arrange(activity)
  }


  if (hide_wp == TRUE) {
    df_yearmon_fct <- df_yearmon_fct %>%
      dplyr::filter(type != "wp")
  }

  if (hide_activity == TRUE) {
    df_yearmon_fct <- df_yearmon_fct %>%
      dplyr::filter(type != "activity")
  }

  df_yearmon_fct
}
