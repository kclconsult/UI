HTMLWidgets.widget({

  name: 'BPTimeline',

  type: 'output',

  factory: function(el, width, height) {

    // Create the chart first
    var chart = null;

    return {

      renderValue: function(x) {

       // if the chart does not exist, create it via c3.generate
        if(chart === null){

            chart = c3.generate({

              // specify the container element we want the chart to render in
                bindto: el,

                data: {
                    type: 'line', // chart type, 'line' is default

                    // intialize with an empty array
                    json: [],

                    keys: {
                          // use timestamp for x-axis
                          x: "timestamp",

                          // use the remaining data for y-values
                          value: ["sbp", "dbp"]
                    },

                    xFormat: "%Y-%m-%d %H:%M:%S", // timestamp format

                    // remap names
                    names: {
                      "sbp": "Systolic blood pressure (SBP)",
                      "dbp": "Diastolic blood pressure (DBP)"
                    },

                    // hide Heart Rate "hr" as there's another Tab
                    hide: ["hr"]

                },

                axis: {
                    x: {
                      //  x axis as timeseries
                      type: "timeseries",

                      // tick format x-axis
                      tick: {
                         format: "%Y-%m-%d"
                      }
                    }
                },

                // hides unused date values, and "hr" Heart Rate
                legend: {
                  hide: ["datem", "date.month", "time", "weekday", "hr"]
                },

                // Reference Lines https://c3js.org/samples/grid_y_lines.html
                grid: {
                  y: {
                    lines: [
                      {value: 85,  text: 'DBP Stage 1',  position: 'start'},
                      {value: 95,  text: 'DBP Stage 2',  position: 'start'},
                      {value: 110, text: 'DBP Severe',  position: 'start'},
                      {value: 135, text: 'SBP Stage 1', position: 'start'},
                      {value: 150, text: 'SBP Stage 2', position: 'start'},
                      {value: 180, text: 'SBP Severe',  position: 'start'}
                    ]
                  }
                }

                // display a subchart - this will be used for brushing in a later stage
                // subchart: {
                //    show: true
                // }
            });
        }

        // at this stage the chart always exists
        // get difference in keys
        // var old_keys = _.keys(chart.x());
        // var new_keys = _.keys(x.dataset);
        // var diff     = _.difference(old_keys,new_keys);

        // update the data and colors
        chart.load({
          json  : x.dataset,
          // colors: x.colors, // let the default colors stand

          // unload data that we don't need anymore
          // unload: diff
        });
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
