if @charts.empty?
  json.benchmark_name nil
  json.charts []
  json.versions []
else
  json.benchmark_name @benchmark_name
  json.charts @charts do |chart|
    datasets = chart.data[:columns]
    json.datasets datasets do |column|
      json.variation column[:name] if datasets.length >= 2
      json.data column[:data]
    end
    json.measurement chart.benchmark_result_type[:name]
    json.unit chart.benchmark_result_type[:unit]
  end
  json.versions @charts[0].data[:categories]
end
