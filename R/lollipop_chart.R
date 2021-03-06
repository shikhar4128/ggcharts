#' Lollipop Chart
#'
#' Easily create a lollipop chart using ggplot2
#'
#' @param data Dataset to use for the bar chart
#' @param x The x variable
#' @param y numeric. If y is missing then it will be assigned the number of records in each group of y
#' @param facet A variable defining the faceting groups
#' @param ... Additional arguments passed to aes()
#' @param line_size character. Size of the lollipop 'stick'
#' @param line_color character. Color of the lollipop 'stick'
#' @param point_size character. Size of the lollipop 'head'
#' @param point_color character. Color of the lollipop 'head'
#' @param highlight A value of \code{x} that should be highlighted in the plot
#' @param sort logical. Should the data be sorted before plotting?
#' @param horizontal logical. Should coord_flip() be added to the plot
#' @param limit integer. If a value for limit is provided only the first limit records will be displayed
#' @param threshold numeric. If a value for threshold is provided only records with y > threshold will be displayed
#'
#' @author Thomas Neitmann
#'
#' @examples
#' data(biomedicalrevenue)
#' revenue2016 <- biomedicalrevenue[biomedicalrevenue$year == 2016, ]
#' revenue_bayer <- biomedicalrevenue[biomedicalrevenue$company == "Bayer", ]
#'
#' ## By default lollipop_chart() creates a horizontal and sorted plot
#' lollipop_chart(revenue2016, company, revenue)
#'
#' ## Create a vertical, non-sorted lollipop chart
#' lollipop_chart(revenue_bayer, year, revenue, horizontal = FALSE, sort = FALSE)
#'
#' ## Limit the number of lollipops to the top 15
#' lollipop_chart(revenue2016, company, revenue, limit = 15)
#'
#' ## Display only companies with revenue > 50B.
#' lollipop_chart(revenue2016, company, revenue, threshold = 50)
#'
#' ## Change the color of the whole lollipop
#' lollipop_chart(revenue2016, company, revenue, line_color = "purple")
#'
#' ## Change the color of the lollipop stick and head individually
#' lollipop_chart(revenue2016, company, revenue, point_color = "darkgreen", line_color = "gray")
#'
#' ## Decrease the lollipop head size
#' lollipop_chart(revenue2016, company, revenue, point_size = 2.5)
#'
#' ## Highlight a single lollipop
#' lollipop_chart(revenue2016, company, revenue, limit = 15, highlight = "Roche")
#'
#' ## Use facets to show the top 10 companies over the years
#' lollipop_chart(biomedicalrevenue, company, revenue, facet = year, limit = 10)
#'
#' @import ggplot2
#' @importFrom magrittr %>%
#' @export
lollipop_chart <- function(data, x, y, facet = NULL, ..., line_size = 0.75,
                           line_color = "#1F77B4", point_size = 4,
                           point_color = line_color, highlight = NULL,
                           sort = TRUE, horizontal = TRUE, limit = NULL,
                           threshold = NULL) {

  x <- rlang::enquo(x)
  y <- rlang::enquo(y)
  facet <- rlang::enquo(facet)
  has_facet <- !rlang::quo_is_null(facet)
  dot_names <- names(rlang::enquos(...))

  data <- pre_process_data(
    data = data, x = !!x, y = !!y,
    facet = !!facet,
    highlight = highlight,
    sort = sort,
    limit = limit,
    threshold = threshold
  )

  .geom_point <- quote(geom_point())
  .geom_segment <- quote(
    geom_segment(aes(y = 0, xend = !!x, yend = !!y), size = line_size)
  )

  if (!"size" %in% dot_names) {
    .geom_point$size <- quote(point_size)
  }
  if (!is.null(highlight)) {
    .geom_segment[[2]]$color <- quote(highlight)
    .geom_point$mapping <- quote(aes(color = highlight))
  } else if (!"color" %in% dot_names) {
    .geom_segment$color <- quote(line_color)
    .geom_point$color <- quote(point_color)
  }

  p <- ggplot(data, aes(!!x, !!y, ...)) +
    eval(.geom_segment) +
    eval(.geom_point) +
    theme_discrete_chart(horizontal)

  post_process_plot(
    plot = p,
    is_sorted = TRUE,
    horizontal = horizontal,
    facet = !!facet,
    fill = FALSE,
    highlight = highlight,
    color = line_color
  )
}
