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

#
# Tab: Recommendations
#
   
renderRecommendations <- function(r) {
  # Render list of Recommendations 
  
  # Args:
  #   r: data.table of the recommendations, each row being a recommendation.
  #      Columns | Description
  #      --------+-----------------------------------------------------------------
  #      heading | String of the Recommendation 
  #      icon    | www/ Relative path to an icon image to load
  #      body    | Recommendation(s), either a single string or a vector of strings.
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
          tags$img(class="media-object", src=paste("images/recommendations/", r$icon[i], ".png", sep=""))
        ),
        tags$div(class="media-body",
          tags$h5(class="media-heading", r$heading[i]),
          # complicated... basically converts a list of strings (r$body) into:
          # <div> 
          #   <p>string1</p>
          #   <p>string2</p>
          #   ...
          # </div> 
          do.call(tags$div, lapply(unlist(r$body[i]), tags$p))
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
  # - loop over feedback objects
  for(i in 1:nrow(f)) {
    # Generates an actionLink with a unique id ("previousFeedback-i"), but not possible to observerEvent("previousFeedback-*")...
    # id = paste("previousFeedback", i, sep="-")
    # t[[i]] <- # append to the tag list, the following tags:
    # actionLink(id, paste(f$datem[i], f$time[i]), class="list-group-item", href = paste("#", id, sep='') )
    
    # ... instead, generate a js to send the timestamp of the feedback as the event:
    onclickjs = paste("Shiny.setInputValue('previousFeedback', '", f$timestamp[i], "', {priority: 'event'});", sep='')
    # And attach that js to an <a> tag:
    t[[i]] <- # append to the tag list, the following tags:
      tags$a(class="list-group-item", paste(f$datem[i], f$time[i]), onclick = onclickjs)
  }
  
  # render the list of tags  
  renderUI({ t })
}