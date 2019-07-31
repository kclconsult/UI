HTMLWidgets.widget({

  name: 'C3Gauge',

  type: 'output',

  factory: function(el, width, height) {

    // create an empty chart
    var chart = null;

    return {

      renderValue: function(x) {

        // does the chart exist?
        if(chart === null) {
          // create a chart and set options

          // note that via the c3.js API we bind the chart ot the element with id equalto chart1
          chart = c3.generate({
            bindto: el,
            data: {
              json: x,
              type: 'gauge',
            },
            gauge: {
              label: {
                // returning here the value and not the ratio
                format: function(value, ratio) { return value; }
              },
              min: 0,
              max: 100,
              width: 15,
              units: 'value' // this is only the text for the label
            }
          });

          // store the chart on el so we can get it later
          el.chart = chart;

        } // ...create the chart

        // at this stage the chart always exists
        // get the chart stored in el and update it
        el.chart.load({json: x});

      }, // ...renderValue

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      } // resize...

    };
  }
});
