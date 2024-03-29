HTMLWidgets.widget({

  name: 'SummaryBox',

  type: 'output',

  factory: function(el, width, height) {

    console.log("SummaryBox w: " + width + " h: " + height);

    var alert_color = {
      "default":   "rgb(126, 126, 133)", // #7E7E85
      "dark":      "rgb(62,54,89)",      // #3E3659
      "blue":      "rgb(68, 148,227)",   // #4494E3
      "green":     "rgb(133,193,58)",    // #85C13A
      "orange":    "rgb(227,147,69)",    // #E39345
      "red":       "rgb(230,64,55)",     // #E64037
      "doublered": "rgb(153,28,21)"      // #991C15
    };

    //  define shared variables for this instance
    var svg = d3.select(el)
      .append("svg")
      .attr("width", width)
      .attr("height", height);

    // pattern definitions
    var defs = svg.append("defs");

    // definition: doublered pattern ...
    var drp = defs.append("pattern")
      .attr("id", "DoubleRedPattern")
      .attr("x", "0")
      .attr("y", "0")
      .attr("width", ".25")  // tiled 4x4 (i.e. swatch takes up 25% of space)
      .attr("height", ".25");
    // .. background is red
    drp.append("rect")
      .attr("x", "0")
      .attr("y", "0")
      .attr("width", "25%")
      .attr("height", "25%")
      .attr("fill", alert_color.red);
    // .. foreground is doublered
    // var a = 4.04; // square-pattern (400x400)
    var a = 3.31; // rect (400x286)
    drp.selectAll("rect.doublered")
      .data([-5*a, -a, 3*a])
      .enter().append("rect")
        .attr("class", "doublered")
        .attr("x", function(d) { return d + "%"; })
        .attr("y", "0")
        // .attr("transform", "rotate(-45)") // square
        .attr("transform", "rotate(-55)") // rect -54.435232006991
        .attr("width", (2*a)+"%")
        .attr("height", "50%")
        .attr("fill", alert_color.doublered);

    // click handler to emit an event for "input${el.id}"
    // https://shiny.rstudio.com/articles/communicating-with-js.html
    $(el).click(function() {
      console.log("SummaryBox " + el.id + " clicked");
      Shiny.setInputValue(el.id, "1", {priority: "event"});
    });

    return {

      renderValue: function(x) {
        console.log("SummaryBox.renderValue: " + x.title + " " + x.alert);

        // x is a dataset with these values:
        // x.title = title,
        // x.image = image,
        // x.alert = alert,
        // x.alert_text = alert_text,
        // x.status = status,
        // x.timestamp = timestamp,
        // x.source = source

        // Places Rounded Rectangle Background with alert color x.alert
        // and looked up by the bg_color map
        var alert_rect_fill = function (d) {
          if(d in alert_color) {
            if(d == "doublered") {
              return "url(#DoubleRedPattern)";
            }
            return alert_color[d];
          } else {
            return alert_color["default"];
          }
        };

        // bind and update the data
        var alert_rect = svg.selectAll("rect.summary-box-alert")
                            .data([x.alert])
                            .style("fill", alert_rect_fill);

        // enter / create the rect
        alert_rect.enter().append("svg:rect")
          .attr("class", function(d) { return "summary-box-alert " + d})
          .attr("x", "15")
          .attr("y", "15")
          .attr("width", width - 30)
          .attr("height", height - 30)
          .attr("rx", "15")
          .style("fill", alert_rect_fill); // initial fill

        // Places the Title for the Summary Box, split across new lines
        // (complicated sub-selection - not updated)
        var title_text = svg.selectAll("text.summary-box-title")
            .data([x.title])
            .enter().append("text")
              .attr("class", "summary-box-title")
              .attr("x", "30")
              .attr("y", "40")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "36px")
              .style("font-weight", "600")
              .selectAll("tspan")
                .data(function(title) { return title.split(" "); })
                .enter().append("tspan")
                  .attr("x", "30")
                  .attr("dy", "1.15em")
                  .text(function(d) { return d; });

        // Status Text
        var status_text = svg.selectAll("text.summary-box-status")
                             .data([x.status])
                             .text(function(d) { return d; });
        // enter / create
        status_text.enter().append("text")
              .attr("class", "summary-box-status")
              .attr("x", "30")
              .attr("y", "189")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "30px")
              .style("font-weight", "500")
              .text(function(d) { return d; });

       // Alert Text
        var alert_text = svg.selectAll("text.summary-box-alert-text")
                             .data([x.alert_text])
                             .text(function(d) { return d; });
        // enter / create
        alert_text.enter().append("text")
              .attr("class", "summary-box-alert-text")
              .attr("x", "370")
              .attr("y", "40")
              .attr("text-anchor", "end")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "24px")
              .style("font-weight", "300")
              .style("font-style", "italic")
              .text(function(d) { return d; });

        // Timestamp Text
        var timestamp_text = svg.selectAll("text.summary-box-timestamp")
                                .data([x.timestamp])
                                .text(function(d) { return d; });
        // enter / create
        timestamp_text.enter().append("text")
              .attr("class", "summary-box-timestamp")
              .attr("x", "30")
              .attr("y", "230")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "20px")
              .style("font-weight", "500")
              .text(function(d) { return d; });

        // (Data) Source Text
        var source_text = svg.selectAll("text.summary-box-source")
                             .data([x.source])
                             .text(function(d) { return "Source: " + d; });
        // enter / create
        source_text.enter().append("text")
              .attr("class", "summary-box-source")
              .attr("x", "30")
              .attr("y", "255")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "20px")
              .style("font-weight", "500")
              .text(function(d) { return "Source: " + d; });

        // Summary Image
        var summary_image = svg.selectAll("image.summary-image")
                                .data([x.image])
                                .attr("xlink:href", function(d) { return d; });
        // enter / create
        summary_image.enter().append("image")
              .attr("class", "summary-image")
              .attr("x", "240")
              .attr("y", "45")
              .attr("height", "125px")
              .attr("width", "125px")
              .attr("xlink:href", function(d) { return d; });

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
