class BenchmarkRunsController < APIController
  def create
    repo = Repo.joins(:organization)
      .where(name: params[:repo], organizations: { name: params[:organization] })
      .first

    # FIXME: Probably bad code.
    if params[:commit_hash]
      initiator = repo.commits.find_by_sha1(params[:commit_hash])
    end

    # FIXME: Probably bad code.
    if params[:version]
      initiator = repo.releases.find_or_create_by!(version: params[:version])
    end

    benchmark_type = repo.benchmark_types.find_or_create_by!(benchmark_type_params)

    benchmark_result_type = BenchmarkResultType.find_or_create_by!(
      benchmark_result_type_params
    )

    benchmark_run = BenchmarkRun.find_or_initialize_by(
      initiator: initiator, benchmark_type: benchmark_type,
      benchmark_result_type: benchmark_result_type
    )

    benchmark_run.update_attributes(benchmark_run_params)
    benchmark_run.result = params[:benchmark_run][:result]

    # TODO: Some notifications feature to say this failed
    benchmark_run.save!

    render nothing: true
  end

  private

  def benchmark_run_params
    params.require(:benchmark_run).permit(:environment)
  end

  def benchmark_type_params
    params.require(:benchmark_type).permit(:category, :script_url)
  end

  def benchmark_result_type_params
    params.require(:benchmark_result_type).permit(:name, :unit)
  end
end
