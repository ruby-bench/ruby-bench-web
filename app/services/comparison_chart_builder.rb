class ComparisonChartBuilder
  attr_accessor :series
  attr_accessor :commit_urls

  def self.construct_from_cache(cache_read, benchmark_result_type)
    chart_builder = new(benchmark_result_type, [])
    chart_builder.series = cache_read[:series]
    chart_builder.commit_urls = cache_read[:commit_urls]

    chart_builder
  end

  def initialize(benchmark_result_type, benchmark_types)
    @benchmark_types = benchmark_types
    @benchmark_result_type = benchmark_result_type
    @series = []
    @commit_urls = []

    build_chart if benchmark_types.present?
  end

  def unit
    @benchmark_result_type.unit
  end

  def name
    @benchmark_result_type.name
  end

  private

  def build_chart
    @benchmark_types.each do |benchmark_type|
      benchmark_type_series_data, benchmark_type_commit_urls = build_data_for(benchmark_type)

      @series << {
        name: benchmark_type.category,
        data: benchmark_type_series_data
      }

      @commit_urls << {
        name: benchmark_type.category,
        data: benchmark_type_commit_urls
      }
    end

    strech_out_series
  end

  def strech_out_series
    @xmin, @xmax = find_xaxis_edges

    @series.each do |s|
      prepend_point(s) && prepend_commit_url(s) unless first_point_is_minimum?(s)
      append_point(s) && append_commit_url(s) unless last_point_is_maximum?(s)
    end
  end

  def prepend_point(s)
    s[:data].insert(0, [@xmin, s[:data].first.second])
  end

  def append_point(s)
    s[:data].push([@xmax, s[:data].last.second])
  end

  def prepend_commit_url(s)
    group = @commit_urls.select { |group| group[:name] == s[:name] }.first
    group[:data].insert(0, '')
  end

  def append_commit_url(s)
    group = @commit_urls.select { |group| group[:name] == s[:name] }.first
    group[:data].push('')
  end

  def first_point_is_minimum?(s)
    s[:data].first.first == @xmin
  end

  def last_point_is_maximum?(s)
    s[:data].last.first == @xmax
  end

  def find_xaxis_edges
    xmin = @series.first[:data].first.first
    xmax = @series.first[:data].last.first

    @series.each do |s|
      s_xmin = s[:data].first.first
      s_xmax = s[:data].last.first

      xmin = s_xmin if s_xmin < xmin
      xmax = s_xmax if s_xmax > xmax
    end

    [xmin, xmax]
  end

  def build_data_for(benchmark_type)
    commit_urls = []
    series_data = []

    BenchmarkRun.fetch_commit_benchmark_runs(benchmark_type.category, @benchmark_result_type, nil)
    .sort_by { |run| run.initiator.created_at }
    .each do |run|
      series_data << [run.initiator.created_at.to_i * 1000, run.result.values[0].to_i]
      commit_urls << commit_url_for(run)
    end

    [series_data, commit_urls]
  end

  def commit_url_for(run)
    commit = run.initiator
    repo = commit.repo
    organization = repo.organization

    "https://github.com/#{organization.name}/#{repo.name}/commit/#{commit.sha1}"
  end
end
