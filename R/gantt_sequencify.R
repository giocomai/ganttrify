#' Establish data sequences that are need for separate elements of the Gantt chart
#'
#' @param projectified Defaults to NULL. Expected to have the exact same format as the data frames generated with [gantt_projectify()]. Takes precedence of `project`.
#' @param ... Arguments passed to [gantt_projectify()]. Ignored if `projectified` is not NULL
#'
#' @return A list, with date and sequence data to be used by [gantt_plotify()].
#' @export
#'
#' @examples
#' gantt_sequencify(project = ganttrify::test_project)
gantt_sequencify <- function(projectified,
                             ...) {

  if (is.null(projectified)) {
    cli::cli_abort(message = c(x = "{.arg projectified} must not be {.code NULL}"))
  }
  
  
  sequence_months <- seq.Date(
    from = min(projectified[["start_date"]]),
    to = max(projectified[["end_date"]]),
    by = "1 month"
  )
  
  if (length(sequence_months) %% 2 != 0) {
    sequence_months <- seq.Date(
      from = min(projectified[["start_date"]]),
      to = max(projectified[["end_date"]]) + 1,
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
      from = min(projectified[["start_date"]] + 15),
      to = max(projectified[["end_date"]] + 15),
      by = paste(month_breaks, "month")
    )),
    frac = 0.5)
  
  
  date_breaks_q <- seq.Date(
    from = lubridate::floor_date(x = min(projectified[["start_date"]]),
                                 unit = "year"),
    to = lubridate::ceiling_date(x = max(projectified[["end_date"]]),
                                 unit = "year"),
    by = "1 quarter"
  )
  
  date_breaks_y <- seq.Date(
    from = lubridate::floor_date(x = min(projectified[["start_date"]]),
                                 unit = "year"),
    to = lubridate::ceiling_date(x = max(projectified[["end_date"]]),
                                 unit = "year"),
    by = "1 year"
  )
  
  list(projectified = projectified, 
       date_range_df = date_range_df,
       date_breaks = date_breaks,
       date_breaks_q = date_breaks_q,
       date_breaks_y = date_breaks_y)
}
