#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
HRTimeline <- function(dataset, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    dataset = dataset
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'HRTimeline',
    x,
    width = width,
    height = height,
    package = 'Consult',
    elementId = elementId
  )
}

#' Shiny bindings for HRTimeline
#'
#' Output and render functions for using HRTimeline within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a HRTimeline
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name HRTimeline-shiny
#'
#' @export
HRTimelineOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'HRTimeline', width, height, package = 'Consult')
}

#' @rdname HRTimeline-shiny
#' @export
renderHRTimeline <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, HRTimelineOutput, env, quoted = TRUE)
}
