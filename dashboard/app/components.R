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
        )
      )
  }
  
  # render the list of tags  
  renderUI({ t })
}


#
# Tab: Feedback
#

renderFeedbackPanel <- function(txt, timestamp) {
  # Render feedback
  #
  # Args:
  #   r: data.table of the recommendations, each row being a previous feedback
  #      Columns | Description
  #      --------+-----------------------------------------------------------------
  #
  # Returns:
  #   Output of a renderUI() of the tags
  #
  
  # <div class="list-group">
  #   <a href="#" class="list-group-item active"><span class="glyphicon glyphicon-exclamation-plus"></span>New Feedback</a>
  #     <a href="#" class="list-group-item active">
  #       Cras justo odio
  #     </a>
  #       <a href="#" class="list-group-item">Dapibus ac facilisis in</a>
  #         <a href="#" class="list-group-item">Morbi leo risus</a>
  #           <a href="#" class="list-group-item">Porta ac consectetur ac</a>
  #             <a href="#" class="list-group-item">Vestibulum at eros</a>
  #               </div>
  
}

renderFeedbackSidebar <- function(feedback) {
  # Render feedback
  #
  # Args:
  #   r: data.table of the recommendations, each row being a previous feedback
  #      Columns | Description
  #      --------+-----------------------------------------------------------------
  #
  # Returns:
  #   Output of a renderUI() of the tags
  #
  
  # <div class="list-group">
  #   <a href="#" class="list-group-item active"><span class="glyphicon glyphicon-exclamation-plus"></span>New Feedback</a>
  #     <a href="#" class="list-group-item active">
  #       Cras justo odio
  #     </a>
  #       <a href="#" class="list-group-item">Dapibus ac facilisis in</a>
  #         <a href="#" class="list-group-item">Morbi leo risus</a>
  #           <a href="#" class="list-group-item">Porta ac consectetur ac</a>
  #             <a href="#" class="list-group-item">Vestibulum at eros</a>
  #               </div>
              
}