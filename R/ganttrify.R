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
#' @param hide_activity Logical, defaults to FALSE. If TRUE, the lines of
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
                      hide_wp = FALSE,
                      wp_label_bold = TRUE,
                      size_activity = 4,
                      hide_activity = FALSE,
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
                      axis_text_align = "right") {
  project <- gantt_verify(
    project = project,
    by_date = by_date,
    exact_date = exact_date
  )

  # arguments consistency check
  if (hide_wp & hide_activity) {
    cli::cli_abort("At least one of {.arg hide_wp} or {.arg hide_activity} must be {.code TRUE}, otherwise there's nothing left to show.")
  }

  projectified <- gantt_projectify(
    project = project,
    by_date = by_date,
    exact_date = exact_date,
    project_start_date = project_start_date,
    colour_palette = colour_palette,
    size_wp = size_wp,
    hide_wp = hide_wp,
    wp_label_bold = wp_label_bold,
    size_activity = size_activity,
    hide_activity = hide_activity,
    label_wrap = label_wrap,
    alpha_wp = alpha_wp,
    alpha_activity = alpha_activity,
    line_end = line_end,
    line_end_wp = line_end_wp,
    line_end_activity = line_end_activity,
    month_breaks = month_breaks
  )

  gg_gantt <- gantt_plotify(projectified = projectified)

  gg_gantt
}
