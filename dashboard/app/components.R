# CONSULT Dashboard HTML Components
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# These are rendering functions which in abstract out the reactive HTML in the server object.
#
# Each renderX(...) function returns a HTML object (through the renderUI...) function
# (See https://shiny.rstudio.com/reference/shiny/1.3.2/renderUI.html).
#

library(humanize)

#
# Tab: Blood Pressure
#

renderAlertBP <- function(alert_text, alert="") {
  # Renders a dismissable bloodpressure alert
  #
  # Args:
  #   alert_text - String to display in alert.
  #   alert - BP flag color, no color defaults to info blue
  #
  # Returns: renderUI object

  # map flag color to alert class
  if(alert == "green") {
    class = "alert-success"
  } else if(alert == "orange") {
    class = "alert-warning"
  } else if(alert == "red") {
    class = "alert-danger"
  } else if(alert == "doublered") {
    class = "alert-danger"
  } else {
    class = "alert-info"
  }

  # Using Bootstrap Alert:
  #    https://getbootstrap.com/docs/3.3/components/#alerts
  #
  # Example:
  # <div class="alert alert-warning alert-dismissible" role="alert">
  # <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
  #    Better check yourself, you're not looking too good.
  # </div>
  t <- tags$div(class=paste("alert",class,"alert-dismissible"),
                role="alert",
                tags$button(type="button",
                            class="close",
                            `data-dismiss`="alert",
                            icon("close")),
                alert_text)

  renderUI({ t })
}

#
# Tab: Mood Grid
#

renderMoodLink <- function(mood) {
  # Renders a Mood Link with a particular mood image
  # TODO - specifiy a ENV for Randomising Mood Images
  img_src = mood_img_src(mood, randomise = TRUE)

  # retrieves which_mood is being displayed
  mood_with_image = mood_from_img_src(img_src)

  # Generate a js to send the mood (and specific mood choice) under a single input$ variable:
  onclickjs = paste("Shiny.setInputValue('moodObservation', '", mood_with_image, "', {priority: 'event'});", sep='')

  # And attach that js to an <a> tag with an image as it's content.
  t = tags$a(tags$img(src = img_src), onclick = onclickjs)

  renderUI({ t })
}

#
# Tab: Recommendations (Tips)
#

renderRecommendations <- function(r) {
  # Render list of Recommendations

  # Args:
  #   r: data.table of the recommendations, each row being a recommendation.
  #      Columns | Description
  #      --------+-----------------------------------------------------------------
  #      heading | String of the Recommendation
  #      icon    | www/ Relative path to an icon image to load
  #      body    | Recommendation(s) as an HTML string to be flat out rendered
  #
  # Returns:
  #   Output of a renderUI() of the tags
  #

  # list of tags (per recommendation)
  t = list()

  # Example of HTML per Recommendation
  #
  # <div class="media">
  #   <div class="media-left media-top">
  #     <img class="media-object" src="images/summary-large.png">
  #   </div>
  #   <div class="media-body">
  #     <h5 class="media-heading">Consider changing your painkiller; there are two options:</h5>
  #     <p>Given your medical history and that paracetamol helps with back pain then paracetamol is recommended. It is recommended that you consider 'paracetamol'.</p>
  #     <p>Given your medical history and that codeine helps with back pain then codeine is recommended.</p>
  #   </div>
  #   <hr />
  # </div>
  #

  # loop over the objects in the recommendations
  for(i in 1:nrow(r)) {
    t[[i]] <- # append to the tag list, the following tags:
      tags$div(class="media",
        tags$div(class="media-left media-top",
          tags$img(class="media-object", src=paste("images/recommendations/", r$image[i], ".png", sep=""))
        ),
        tags$div(class="media-body",
          tags$h5(class="media-heading", r$title[i]),
          # r$body is rendered as HTML as is:
          HTML(r$content[i])
          #######################################################################
          # Previous Implmentation converted a list of strings (r$body[i]) into:
          # <div>
          #   <p>string1</p>
          #   <p>string2</p>
          #   ...
          # </div>
          # do.call(tags$div, lapply(unlist(r$body[i]), tags$p))
          ######################################################################
        ),
        # horizontal line between recommendations
        tags$hr()
      )
  }

  # render the list of tags
  renderUI({ t })
}


#
# Tab: Feedback (Clinical Impressions)
#

renderFeedbackPanel <- function(text, timestamp) {
  # Render previous feedback (clinical impressions)
  #
  # Args:
  #   r: data.table of the recommendations, each row being a previous feedback
  #      Columns | Description
  #      --------+-----------------------------------------------------------------
  #
  # Returns:
  #   Output of a renderUI() of the tags
  #

  # render the list of tags
  renderUI(tagList(
    tags$h4(timestamp),
    tags$p(text)
  ))
}

renderPreviousFeedbackList <- function(f, previousFeedback) {

  if(!is.null(f)) {

    # Render a listing of previous feedback for a sideback
    #
    # Args:
    #   f: data.table of the feedback, each row being a previous feedback
    #      Columns | Description
    #      --------+-----------------------------------------------------------------
    #
    # Returns:
    #   Output of a renderUI() of the tags
    #

    # Example of each feedback item
    # <a href="#" class="list-group-item">Time Stamp...</a>

    # list of tags (per feedback)
    t = list()

    # Prepend the New Feedback option
    # - loop over the rows in f (the feedback objects)
    for(i in 1:nrow(f)) {
      # About 20 chars can fit in the label.

      # Time-stamp as the label (e.g. "2019-08-22 13:34:10")
      #label = paste(f$datem[i], f$time[i])

      # Date + 10 char preview and an ellipse (if note > 10 chars)
      label = paste(f$datem[i], substring(f$note[i], 1, 10), `if`(str_length(f$note[i]) > 10, "...", ""))

      # Display timestamp as "time ago..."
      # NOTE: Discrepency with server-time makes recent feedback seem like it's in the future
      # label = natural_time(f$timestamp[i])

      # Generates an actionLink with a unique id ("previousFeedback-i"), but not possible to observerEvent("previousFeedback-*")...
      # id = paste("previousFeedback", i, sep="-")
      # t[[i]] <- # append to the tag list, the following tags:
      # actionLink(id, paste(f$datem[i], f$time[i]), class="list-group-item", href = paste("#", id, sep='') )

      # ... instead, generate a js to send the timestamp of the feedback as the event:
      onclickjs = paste("Shiny.setInputValue('previousFeedback', '", f$timestamp[i], "', {priority: 'event'});", sep='')
      # And attach that js to an <a> tag:
      t[[i]] <- # append to the tag list, the following tags:
        tags$a(class="list-group-item", label, onclick = onclickjs)
    }

    # render the list of tags
    renderUI({ t })

  }

}
