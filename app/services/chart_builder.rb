class ChartBuilder
  
  # @columns is JSON that looks like [{ name: "benchmark1", data: [1.1, 1.2] }]
  # @categories is a an array of version hashes: 
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
  attr_accessor :columns, :categories

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

    chart_builder.categories = cache_read[:versions]
    chart_builder.columns = cache_read[:datasets]
    chart_builder
  end

  def initialize(benchmark_runs, benchmark_result_type)
    @benchmark_result_type = benchmark_result_type
    @benchmark_runs = benchmark_runs
    @columns = {}
  end

  def build_columns
    @benchmark_runs.each do |benchmark_run|
      if block_given?
        version = yield(benchmark_run)
        @categories ||= []
        @categories << version if version != @categories.last
      end

      benchmark_run.result.each do |key, value|
        @columns[key] ||= []
        @columns[key] << value.to_f
      end
    end

    new_columns = []

    @columns.each do |name, data|
      new_columns << { name: name, data: data}
    end

    @columns = new_columns
    self
  end
end
