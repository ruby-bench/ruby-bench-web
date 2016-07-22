class ChartBuilder
  def initialize(benchmark_runs)
    @benchmark_runs = benchmark_runs
    @data = {}
    @data[:columns] = {}
  end

  def build_columns
    @benchmark_runs.each do |benchmark_run|
      if block_given?
        @data[:categories] ||= []
        @data[:categories] << yield(benchmark_run)
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
end
