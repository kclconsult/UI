HTMLWidgets.widget({

  name: 'SummaryBox',

  type: 'output',

  factory: function(el, width, height) {

    console.log("SummaryBox w: " + width + " h: " + height);

    var bg_color = {
      "default": "rgb(186,186,196)",
      "dark":    "rgb(62,54,89)",
      "green":   "rgb(133,193,58)",
      "orange":  "rgb(227,147,69)",
      "red":     "rgb(230,64,55)"   // #E64037
    };

    //  define shared variables for this instance
    var svg = d3.select(el)
      .append("svg")
      .attr("width", width)
      .attr("height", height);

    return {

      renderValue: function(x) {
        // x is a dataset with these values:
        // x.title = title,
        // x.alert = alert,
        // x.status = status,
        // x.timestamp = timestamp,
        // x.source = source

        // Places Rounded Rectangle Background with alert color x.alert
        // and looked up by the bg_color map
        var alert_rect = svg.selectAll("rect.summary-box-alert")
                .data([x.alert])
                .enter().append("svg:rect")
                  .attr("class", "summary-box-alert")
                  .attr("x", "15")
                  .attr("y", "15")
                  .attr("width", width - 30)
                  .attr("height", height - 30)
                  .attr("rx", "15")
                  .style("fill", function (d) {
                    if(d in bg_color) {
                      return bg_color[d];
                    } else {
                      return bg_color["default"];
                    }
                  });

        // Places the Title for the Summary Box, split across new lines
        var title_text = svg.selectAll("text.summary-box-title")
            .data([x.title])
            .enter().append("text")
              .attr("class", "summary-box-title")
              .attr("x", "30")
              .attr("y", "40")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "40px")
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
            .enter().append("text")
              .attr("class", "summary-box-status")
              .attr("x", "30")
              .attr("y", "210")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "40px")
              .style("font-weight", "500")
              .text(function(d) { return d; });

        // Timestamp Text
        var timestamp_text = svg.selectAll("text.summary-box-timestamp")
            .data([x.timestamp])
            .enter().append("text")
              .attr("class", "summary-box-timestamp")
              .attr("x", "30")
              .attr("y", "281")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "24px")
              .style("font-weight", "500")
              .text(function(d) { return d; });

        // (Data) Source Text
        var timestamp_text = svg.selectAll("text.summary-box-source")
            .data([x.source])
            .enter().append("text")
              .attr("class", "summary-box-source")
              .attr("x", "30")
              .attr("y", "310")
              .style("fill", "rgb(255,255,255)")
              .style("font-size", "24px")
              .style("font-weight", "500")
              .text(function(d) { return "Source: " + d; });
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
