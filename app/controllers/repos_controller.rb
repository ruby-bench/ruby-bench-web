class ReposController < ApplicationController
  def show
    @organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(@organization, params[:repo_name])
    @form_result_type = params[:result_type]
    benchmark_runs = fetch_benchmark_runs(@repo.commits, 'Commit')

    if @form_result_type
      chart_builder = ChartBuilder.new(
        benchmark_runs.where(category: @form_result_type).sort_by do |benchmark_run|
          benchmark_run.initiator.created_at
        end
      )

      @chart_columns = chart_builder.build_columns do |benchmark_run|
        "
          Commit: #{benchmark_run.initiator.sha1[0..6]}<br>
          Commit Date: #{benchmark_run.initiator.created_at}<br>
          Environment: #{benchmark_run.environment}
        ".squish
      end
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_benchmark_runs_categories(benchmark_runs)
      end

      format.js
    end
  end

  def show_releases
    @organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(@organization, params[:repo_name])
    releases = @repo.releases
    @form_result_type = params[:result_type]
    benchmark_runs = fetch_benchmark_runs(releases, 'Release')

    if @form_result_type
      chart_categories ||= ['Ruby Version']

      chart_builder = ChartBuilder.new(
        benchmark_runs.where(category: @form_result_type).sort_by do |benchmark_run|
          benchmark_run.initiator.version
        end
      )

      @chart_columns = chart_builder.build_columns do |benchmark_run|
        benchmark_run.initiator.version
      end
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_benchmark_runs_categories(benchmark_runs)
      end

      format.js
    end
  end

  private

  def find_organization_by_name(name)
    Organization.find_by_name(params[:organization_name]) || not_found
  end

  def find_organization_repos_by_name(organization, name)
    organization.repos.find_by_name(name)
  end

  def fetch_benchmark_runs(initiators, initiator_type)
    BenchmarkRun.initiators(initiators.map(&:id), initiator_type)
      .preload(:initiator)
  end

  def fetch_benchmark_runs_categories(benchmark_runs)
    benchmark_runs.pluck(:category).uniq.sort.group_by do |category|
      category =~ /\A([^_]+)_/
      $1
    end
  end
end
