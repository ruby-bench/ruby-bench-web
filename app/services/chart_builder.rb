class ChartBuilder
  def initialize(benchmark_runs)
    @benchmark_runs = benchmark_runs
    @data = {}
    @data[:categories] = []
    @data[:columns] = {}
  end

  def build_columns
    if !@benchmark_runs.empty?
      @benchmark_runs.each do |benchmark_run|
        if block_given?
          @data[:categories] << yield(benchmark_run)
        end

        benchmark_run.result.each do |key, value|
          @data[:columns][key] ||= []
          @data[:columns][key] << value.to_f
        end
      end

      new_columns = []
      visible = true
      @data[:columns].each do |name, data|
        new_columns << { name: name, data: data, visible: visible }
        visible = false
      end
      @data[:columns] = new_columns.to_json

      @data
    end
  end
end
