HTMLWidgets.widget({

  name: 'HRTimeline',

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
                          value: ["hr", "hr.resting"]
                    },

                    xFormat: "%Y-%m-%d %H:%M:%S", // timestamp format

                    // remap names
                    names: {
                      "hr": "Heart Rate",
                      "hr.resting": "Heart Rate (Resting)",
                      "activity.freq": "Activity Frequency"
                    }
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

                // hides unused date values
                legend: {
                  hide: ["datem", "date.month", "time", "weekday"]
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
