class ChartBuilder
  # @columns is an array that looks like [{ name: "benchmark1", data: [1.1, 1.2] }]
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
    chart_builder = self.new([], benchmark_result_type)

    chart_builder.categories = cache_read[:versions]
    chart_builder.columns = cache_read[:datasets]
    chart_builder
  end

  def initialize(benchmark_runs, benchmark_result_type, comparing_runs = [])
    @benchmark_result_type = benchmark_result_type
    @benchmark_runs = benchmark_runs
    @columns = {}
    @comparing_runs = comparing_runs
  end

  def build_columns
    columns = {}

    if @comparing_runs.present?
      runs = (@benchmark_runs + @comparing_runs)
      .sort_by { |run| run.initiator.created_at }
    else
      runs = @benchmark_runs
    end

    runs.each do |run|
      version = nil
      if block_given?
        version = yield(run)
        @categories ||= []
        @categories << version if version != @categories.last
      end

      run.result.each do |key, value|
        if @comparing_runs.present?
          columns["#{key}_#{run.benchmark_type.category}"] ||= []
          columns["#{key}_#{run.benchmark_type.category}"] << [version, value.to_f]
        else
          columns[key] ||= []
          columns[key] << value.to_f
        end
      end
    end

    @columns = columns.map do |name, data|
      { name: name, data: data }
    end

    self
  end
end
