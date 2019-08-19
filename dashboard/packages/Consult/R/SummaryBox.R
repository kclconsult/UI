#' SummaryBox Widget
#'
#' Displays a Box with some Titles and Status for the Summary of a Data field for a particular user
#'
#' @import htmlwidgets
#'
#' @export
SummaryBox <- function(title="", image="images/summary/default.png", alert="default", status="", timestamp="", source="", connectivity="connected", width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    title = title,
    image = image,
    alert = alert,
    status = status,
    timestamp = timestamp,
    source = source,
    connectivity = connectivity
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'SummaryBox',
    x,
    width = width,
    height = height,
    package = 'Consult',
    elementId = elementId
  )
}

#' Shiny bindings for SummaryBox
#'
#' Output and render functions for using SummaryBox within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a SummaryBox
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name SummaryBox-shiny
#'
#' @export
SummaryBoxOutput <- function(outputId,
                             #width = '344px', height = '344px'){
                             width = '400px', height = '320px') {
  htmlwidgets::shinyWidgetOutput(outputId, 'SummaryBox', width, height, package = 'Consult')
}

#' @rdname SummaryBox-shiny
#' @export
renderSummaryBox <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, SummaryBoxOutput, env, quoted = TRUE)
}
