require 'uri'
require 'net/http'
require 'json'

class BenchmarkRegressionJob < ActiveJob::Base
  queue_as :default

  def perform(benchmark_run_id)
    benchmark_run = BenchmarkRun.find_by_id(benchmark_run_id)
    categories = benchmark_run.result.keys
    current_commit = benchmark_run.initiator
    previous_commits = Commit.where('created_at < ?', current_commit.created_at).where(repo: current_commit.repo).limit(1000)
    previous_benchmark_runs = BenchmarkRun.where(initiator: previous_commits, benchmark_type: benchmark_run.benchmark_type,
                                                 benchmark_result_type: benchmark_run.benchmark_result_type)

    categories.each do |category|
      previous_benchmark_results = previous_benchmark_runs.map { |run| run.result[category].to_f }
      results_average = average(previous_benchmark_results)
      results_param = results_average + 2*standard_deviation(previous_benchmark_results, results_average)
      if benchmark_run.result[category].to_f > results_param && check_equal(benchmark_run, category, results_param)
        create_issue benchmark_run, category, results_param
      end
    end
  end

  def create_issue(benchmark_run, category, results_param)
    uri = URI.parse(Rails.application.secrets.github_api)
    http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request.basic_auth 'RubyBenchBot', Rails.application.secrets.github_password
    request.body = {"title" => "Benchmark Regression Detected",
                    "body" => request_body(benchmark_run, category, results_param)}.to_json
    response = http_client.request(request)
    raise StandardError, "Request failed with response code #{response.code}" if response.code != "201"
    response
  end

  def average(previous_benchmark_results)
    previous_benchmark_results.inject{|sum, el| sum + el}.to_f / previous_benchmark_results.size
  end

  def standard_deviation(previous_benchmark_results, results_average)
    Math.sqrt(previous_benchmark_results.inject(0){|accum, i| accum + (i - results_average)**2} / (previous_benchmark_results.size - 1).to_f)
  end

  def request_body(benchmark_run, category, results_param)
    "Benchmark Regression has been detected:
    repo: #{benchmark_run.initiator.repo.name}
    benchmark_category: #{category}
    benchmark_type: #{benchmark_run.benchmark_type.category}
    benchmark_result_type: #{benchmark_run.benchmark_result_type.name}
    Diversion: #{((benchmark_run.result[category].to_f - results_param) / results_param) * 100}%"
  end

  def check_equal(benchmark_run, category, results_param)
    url = URI.parse(Rails.application.secrets.github_api+"?state=open&since=#{get_time}")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url.to_s)
    http.use_ssl = true
    res = http.request(request)
    raise StandardError, "Request failed with response code #{res.code}" if res.code != "200"
    response = JSON.parse(res.body)

    response.each do |response|
      if request_body(benchmark_run, category, results_param).split(/Diversion/).first.eql? response["body"].split(/Diversion/).first
        return false
      end
    end
  end

  def get_time
    time_before_iso = Time.parse((Time.current - (60 * 60 * 24 * 30)).to_s).utc.iso8601
  end
end
