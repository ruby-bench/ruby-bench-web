class BenchmarkRunsController < APIController
  def create
    repo = Repo.joins(:organization)
               .where(name: params[:repo], organizations: { name: params[:organization] })
               .first

    initiator =
      if params[:commit_hash]
        repo.commits.find_by_sha1(params[:commit_hash])
      elsif params[:version]
        repo.releases.find_or_create_by!(version: params[:version])
      end

    benchmark_type = repo.benchmark_types.find_or_create_by!(
      category: benchmark_type_params[:category],
      script_url: benchmark_type_params[:script_url]
    )

    benchmark_type.update_attributes(digest: benchmark_type_params[:digest])

    benchmark_result_type = BenchmarkResultType.find_or_create_by!(
      benchmark_result_type_params
    )

    benchmark_run = BenchmarkRun.find_or_initialize_by(
      initiator: initiator,
      benchmark_type: benchmark_type,
      benchmark_result_type: benchmark_result_type
    )

    benchmark_run.update_attributes(benchmark_run_params)
    benchmark_run.result = params[:benchmark_run][:result].to_unsafe_h
    benchmark_run.validity = true
    benchmark_run.save!

    $redis.keys("*#{BenchmarkRun.charts_cache_key(benchmark_type, benchmark_result_type)}*").each do |key|
      $redis.del(key)
    end

    head :ok
  end

  private

  def benchmark_run_params
    params.require(:benchmark_run).permit(:environment)
  end

  def benchmark_type_params
    params.require(:benchmark_type).permit(:category, :script_url, :digest)
  end

  def benchmark_result_type_params
    params.require(:benchmark_result_type).permit(:name, :unit)
  end
end
