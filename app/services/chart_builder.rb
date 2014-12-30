class ChartBuilder
  def initialize(benchmark_runs)
    @benchmark_runs = benchmark_runs
    @categories = []
  end

  def build_columns(&block)
    columns = build_data(&block)

    if !columns.empty?
      columns.map do |result_type, result_data|
        graphs_columns = [@categories]

        result_data.map do |_, value|
          graphs_columns << value
        end

        graphs_columns
      end
    end
  end

  private

  def build_data
    data ||= {}

    @benchmark_runs.each do |benchmark_run|
      if block_given?
        @categories << yield(benchmark_run)
      end

      benchmark_run.result.each do |key, value|
        data[benchmark_run.category] ||= {}
        data[benchmark_run.category][:unit] ||= benchmark_run.unit
        data[benchmark_run.category][:script_url] ||= benchmark_run.script_url
        data[benchmark_run.category][:category] ||= benchmark_run.category
        data[benchmark_run.category][key] ||= []
        data[benchmark_run.category][key] << value.to_f
      end
    end

    data
  end
end
