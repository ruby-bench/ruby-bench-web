class ChartBuilder
  
  # @data[:columns] is JSON that looks like [{ name: "benchmark1", data: [1.1, 1.2] }]
  # @data[:categories] is JSON that looks like [version_html_string, version_html_string]
  attr_accessor :data
  
  # @versions is a hash that holds all version/environment information for each datapoint, 
  #   and gets converted to html and stored in @data[:categories]
  attr_accessor :versions

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

    chart_builder.versions = cache_read[:versions]
    chart_builder.data[:categories] = chart_builder.versions.map { |version| hash_to_html(version) }.to_json
    chart_builder.data[:columns] = cache_read[:datasets].to_json
    chart_builder
  end

  def initialize(benchmark_runs, benchmark_result_type)
    @benchmark_result_type = benchmark_result_type
    @benchmark_runs = benchmark_runs
    @versions = []
    @data = {}
    @data[:columns] = {}
  end

  def build_columns
    @benchmark_runs.each do |benchmark_run|
      if block_given?
        version = yield(benchmark_run)
        @data[:categories] ||= []
        if version != @versions.last
          @versions << version
          @data[:categories] << ChartBuilder.hash_to_html(version)
        end
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

    if @data[:categories]
      @data[:categories] = @data[:categories].to_json
    end

    @data
  end

  private

  # Generate an HTML string representing the `hash`, with each pair on a new line
  def self.hash_to_html(hash)
    hash.map do |k, v|
      if k == :environment
        v
      else
        new_key = k.to_s.split('_').map { |word| word.capitalize }.join(' ')
        "#{new_key}: #{v}" 
      end
    end.join("<br>")
  end
end
