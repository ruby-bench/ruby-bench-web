class BenchmarkRunsController < APIController
  def create
    benchmark_run = BenchmarkRun.new(benchmark_run_params)
    benchmark_run.result = params[:benchmark_run][:result]

    # Remove this once Github hook is actually coming from the original Ruby
    # repo.
    if params[:organization] == 'tgxworld'
      params[:organization] = 'ruby'
    end

    repo = Organization.find_by_name(params[:organization])
      .repos.find_by_name(params[:repo])

    # FIXME: Probably bad code.
    if params[:commit_hash]
      benchmark_run.initiator = repo.commits.find_by_sha1(params[:commit_hash])
    end

    # FIXME: Probably bad code.
    if params[:ruby_version]
      release = repo.releases.find_or_create_by!(version: params[:ruby_version])
      benchmark_run.initiator = release
    end

    benchmark_type = repo.benchmark_types.find_or_create_by!(benchmark_type_params)
    benchmark_run.benchmark_type = benchmark_type

    # TODO: Some notifications feature to say this failed
    benchmark_run.save!

    render nothing: true
  end

  private

  def benchmark_run_params
    params.require(:benchmark_run).permit(
      :environment
    )
  end

  def benchmark_type_params
    params.require(:benchmark_type).permit(
      :category, :unit, :script_url
    )
  end
end
