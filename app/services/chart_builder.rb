class ChartBuilder
  
  # @data[:columns] is JSON that looks like [{ name: "benchmark1", data: [1.1, 1.2] }]
  # @data[:categories] is a an array of version hashes: 
  # [
  #   {
  #     version: "0",
  #     environment: "ruby 2.2.0dev"
  #   },
  #   {
  #     version: "0",
  #     environment: "ruby 2.2.0dev"
  #   }
  # ]
  attr_accessor :data

  # the metric this benchmark measures, which looks like:
  # {
  #   name: "Memory used",
  #   unit: "Bytes"
  # }
  attr_reader :benchmark_result_type

  # `cache_read` looks like 
  # { datasets: [{ name: "benchmark1", data: [1.1, 1.2] }], versions: [version_hash, version_hash] }
  def self.construct_from_cache(cache_read, benchmark_result_type)
    chart_builder = ChartBuilder.new([], benchmark_result_type)

    chart_builder.data[:categories] = cache_read[:versions]
    chart_builder.data[:columns] = cache_read[:datasets].to_json
    chart_builder
  end

  def initialize(benchmark_runs, benchmark_result_type)
    @benchmark_result_type = benchmark_result_type
    @benchmark_runs = benchmark_runs
    @data = {}
    @data[:columns] = {}
  end

  def build_columns
    @benchmark_runs.each do |benchmark_run|
      if block_given?
        version = yield(benchmark_run)
        @data[:categories] ||= []
        @data[:categories] << version if version != @data[:categories].last
      end

      benchmark_run.result.each do |key, value|
        @data[:columns][key] ||= []
        @data[:columns][key] << value.to_f
      end
    end

    new_columns = []

    @data[:columns].each do |name, data|
      new_columns << { name: name, data: data}
    end

    @data[:columns] = new_columns.to_json

    @data
  end
end
