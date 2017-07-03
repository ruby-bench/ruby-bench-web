class BenchmarkRunsController < APIController
  def create
    repo = Repo.joins(:organization)
      .where(name: params[:repo], organizations: { name: params[:organization] })
      .first

    initiator =
      if params[:commit_hash]
        initiator = repo.commits.find_by_sha1(params[:commit_hash])
      elsif params[:version]
        initiator = repo.releases.find_or_create_by!(version: params[:version])
      end

    benchmark = repo.benchmarks.find_or_create_by!(
      label: benchmark_params[:label],
      script_url: benchmark_params[:script_url]
    )

    benchmark.update_attributes(digest: benchmark_params[:digest])

    result_type = ResultType.find_or_create_by!(
      result_type_params
    )

    benchmark_run = BenchmarkRun.find_or_initialize_by(
      initiator: initiator, benchmark: benchmark,
      result_type: result_type
    )

    benchmark_run.update_attributes(benchmark_run_params)
    benchmark_run.result = params[:benchmark_run][:result].to_unsafe_h
    benchmark_run.save!

    $redis.keys("#{BenchmarkRun.charts_cache_key(benchmark, result_type)}:*").each do |key|
      $redis.del(key)
    end

    head :ok
  end

  private

  def benchmark_run_params
    params.require(:benchmark_run).permit(:environment)
  end

  def benchmark_params
    params.require(:benchmark).permit(.label, :script_url, :digest)
  end

  def result_type_params
    params.require(:result_type).permit(:name, :unit)
  end
end
