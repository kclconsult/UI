#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
SummaryBox <- function(title, alert, status, timestamp, source, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    title = title,
    alert = alert,
    status = status,
    timestamp = timestamp,
    source = source
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
SummaryBoxOutput <- function(outputId, width = '344px', height = '344px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'SummaryBox', width, height, package = 'Consult')
}

#' @rdname SummaryBox-shiny
#' @export
renderSummaryBox <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, SummaryBoxOutput, env, quoted = TRUE)
}