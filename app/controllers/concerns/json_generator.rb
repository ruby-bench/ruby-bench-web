require 'active_support/concern'

module JSONGenerator
  extend ActiveSupport::Concern

  # Generate the JSON representation of `charts`
  def generate_json(charts, params = {})
    charts.map do |chart|
      datasets = []
      variations = []
      # each column contains an array of datapoints
      JSON.parse(chart.data[:columns], symbolize_names: true).each do |column|
        # get one set of datapoints (sometimes there's 2+ sets of data for one chart)
        datasets << column[:data]
        # This is for when there are two data sets in one chart (ex. rails commits benchmarks)
        # Example variations: `with_prepared_statements`, `without_prepared_statements`
        # `column['name']` is the benchmark name when there is only one set of datapoints
        variations << column[:name]
      end

      # `datasets` looks like [ [1, 2, 3], [5, 6, 7] ] where each dataset represents
      #   the y-axis points for a line on the graph - but the 1st element from each dataset
      #   corresponds to the same x-axis point in the graph, so we zip them together so that
      #   we don't repeat the version object in our JSON
      # 
      # before: [ [1, 2, 3], [5, 6, 7] ]
      # after: [ [1, 5], [2, 6], [3, 7] ] (where each sub-array corresponds to one x-axis
      #   point)
      first, *rest = *datasets
      datasets_zip = first.zip(*rest)

      # now that we zipped our datasets together, we can add in the version object that corresponds
      #   to each subarray in `datasets_zip`
      #
      # before: [ [1, 5], [2, 6], [3, 7] ]
      # after: [
      #   {
      #     values: [1, 5],
      #     version: { version: 1 }
      #   },
      #   {
      #     values: [2, 6],
      #     version: { version: 2 }
      #   },
      #   {
      #     values: [3, 7],
      #     version: { version: 3 }
      #   }
      # ]
      datapoints = datasets_zip.zip(chart.versions).reduce([]) do |memo, (points, version)|
        memo << {
          values: points,
          version: version
        }
        memo
      end

      # generate the json
      config = {
        benchmark_name: params[:result_type],
        datapoints: datapoints,
        measurement: chart.benchmark_result_type[:name],
        unit: chart.benchmark_result_type[:unit]
      }
      config[:variations] = variations if variations.length > 1
      config
    end
  end
end
