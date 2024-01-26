#' Check the consistency of the input project data frame
#'
#' Check the consistency of the input project data frame, return meaningful errors or warnings if something is not quite right
#'
#' @inheritParams ganttrify
#'
#' @return A data frame (a tibble) that is consistent with the format expected by [ganttrify()].
#' @export
#'
#' @examples
#' gantt_verify(project = ganttrify::test_project)
#' @importFrom rlang .data
gantt_verify <- function(project,
                         by_date = FALSE,
                         exact_date = FALSE) {
  if (is.data.frame(project) == FALSE) {
    cli::cli_abort("{.arg project} must be a data frame.")
  }

  if (ncol(project) < 4) {
    cli::cli_abort("{.arg project} must must have (at least) four columns.")
  }

  project <- tibble::as_tibble(project)

  if (identical(colnames(project)[1:4], colnames(ganttrify::test_project)) == FALSE) {
    cli::cli_warn(c(
      x = "{.arg project} is expected to have (at least) four columns, in this order: {stringr::str_flatten_comma(string = colnames(ganttrify::test_project))}.",
      i = "The first four columns of this data frame will be treated as such, even if column names are different."
    ))
    colnames(project)[1:4] <- colnames(ganttrify::test_project)
  }


  if (by_date) {
    project <- project %>%
      dplyr::mutate(
        wp = as.character(.data[["wp"]]),
        activity = as.character(.data[["activity"]]),
        start_date = as.character(.data[["start_date"]]),
        end_date = as.character(.data[["end_date"]])
      )
  } else {
    project <- project %>%
      dplyr::mutate(
        wp = as.character(.data[["wp"]]),
        activity = as.character(.data[["activity"]]),
        start_date = as.numeric(.data[["start_date"]]),
        end_date = as.numeric(.data[["end_date"]])
      )
  }

  if (exact_date) {
    project <- project %>%
      dplyr::mutate(
        wp = as.character(.data[["wp"]]),
        activity = as.character(.data[["activity"]]),
        start_date = lubridate::as_date(.data[["start_date"]]),
        end_date = lubridate::as_date(.data[["end_date"]])
      )
  }

  na_count_v <- sapply(X = project[1:4], FUN = function(x) sum(is.na(x)))

  if (sum(na_count_v) > 0) {
    project_pre_nrow_v <- nrow(project)
    project <- tidyr::drop_na(project)
    project_post_nrow_v <- nrow(project)

    effective_na_v <- na_count_v[na_count_v > 0]

    cli::cli_warn(message = c(
      x = "{.val {sum(effective_na_v)}} missing values or wrong format found in the following column{?s}: {.field {stringr::str_flatten_comma(names(effective_na_v))}}",
      i = "{.val {project_pre_nrow_v-project_post_nrow_v}} rows with invalid values have been dropped."
    ))
  }

  project
}
