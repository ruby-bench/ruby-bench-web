class ChartBuilder
  def initialize(benchmark_runs)
    @benchmark_runs = benchmark_runs.to_a
  end

  def build_columns
    if !@benchmark_runs.empty?
      data ||= {}
      data[:categories] ||= []
      data[:columns] ||= {}

      @benchmark_runs.each do |benchmark_run|
        data[:category] ||= benchmark_run.category
        data[:unit] ||= benchmark_run.unit
        data[:script_url] ||= benchmark_run.script_url

        if block_given?
           data[:categories] << yield(benchmark_run)
        end

        benchmark_run.result.each do |key, value|
          data[:columns][key] ||= []
          data[:columns][key] << value.to_f
        end
      end

      new_columns = []
      data[:columns].each do |name, data|
        new_columns << { name: name, data: data }
      end
      data[:columns] = new_columns.to_json

      data
    end
  end
end
