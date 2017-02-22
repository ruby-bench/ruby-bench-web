require 'active_support/concern'

module JSONGenerator
  extend ActiveSupport::Concern

  # Generate the JSON representation of `charts`
  def generate_json(charts, versions, params = {})
    charts.map do |result_data, result_type|
      datasets = []
      variations = []
      # each column contains an array of datapoints
      JSON.parse(result_data[:columns]).each do |column| 
        # get one set of datapoints (sometimes there's 2+ sets of data for one chart)
        datasets << column['data']
        # This is for when there are two data sets in one chart (ex. rails commits benchmarks)
        # Example variations: `with_prepared_statements`, `without_prepared_statements`
        # `column['name']` is the benchmark name when there is only one set of datapoints
        variations << column['name']
      end

      # zip the multiple datapoints together
      first, *rest = *datasets
      datasets_zip = first.zip(*rest)

      # combine the datapoints with their respective versions
      # `datasets_zip` and `versions` have the same length
      datapoints = datasets_zip.zip(versions).reduce([]) do |memo, (points, version)|
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
        measurement: result_type[:name],
        unit: result_type[:unit]
      }
      config[:variations] = variations if variations.length > 1
      config
    end
  end
end