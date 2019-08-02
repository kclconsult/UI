# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# These are rendering functions which in abstract out the reactive HTML in the server object.
#
# Each renderX(...) function returns a HTML object (through the renderUI...) function
# (See https://shiny.rstudio.com/reference/shiny/1.3.2/renderUI.html).
#

# Button Alert
renderButtonAlert <- function(times) {
  # Render a Bootstrap alert: https://getbootstrap.com/docs/3.3/components/#alerts

  # <div class="alert alert-success" role="alert">
  #   Button Pressed: N times!
  # </div>

  # NOTE: in R the "return" value is the last value evaluated in a function,
  # so this returns the rendered HTML expression:
  renderUI({
    tags$div(class="alert alert-success", role="alert",
             paste("Button Pressed:", times, "times!"))
  })
  # Note: paste concatenates strings (with a DEFAULT single whitespace character): 
  # https://www.rdocumentation.org/packages/base/versions/3.6.1/topics/paste
}

# Slider Progress Bar
renderSliderProgress <- function(progressValue) {
  # Render a Bootstrap Progress Bar: https://getbootstrap.com/docs/3.3/components/#progress
  print("renderSliderProgress")
  print(progressValue)

  # {{ progressValue }} is the stub for the progress value:
  #    <div class="progress">
  #      <div class="progress-bar progress-bar-warning progress-bar-striped" role="progressbar"
  #           aria-valuenow="{{ progressValue }}" aria-valuemin="0" aria-valuemax="100" style="width: {{ progressValue }}%">
  #        <span class="sr-only">{{ progressValue }}</span>
  #      </div>
  #    </div>

  renderUI(
    # withTags saves having to type tags$ infront of each tag object:
    withTags({ 
        div(class="progress",
            div(class="progress-bar progress-bar-warning progress-bar-striped",
                role="progressbar",
                
                # NOTE: as.character() is a general way to convert integer to string.
                # NOTE2: backticks, i.e. ``, surround non-standard attribute names,
                # i.e. aria-valuenow, to make them R function safe attributes
                `aria-valuenow`= as.character(progressValue),
                
                `aria-valuemin`="0",
                `aria-valuemax`="100",
                
                # NOTE: paste0 concatenates strings with out a blank ' ' space
                # as separating character (which is default for paste())
                style=paste0("width:", progressValue, "%"),
                
                tags$span(class="sr-only", progressValue)
            )
        )
    })
  )
}