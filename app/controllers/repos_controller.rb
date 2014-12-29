class ReposController < ApplicationController
  # ZOMG too much logic here and we really need to clean this up.
  # ActiveRecord queries are taking wayyy tooo long.
  def show
    organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(organization, params[:repo_name])
    @form_result_types = sort_form_result_types(params[:result_types])
    benchmark_runs = fetch_benchmark_runs(@repo.commits, 'Commit')
    @result_types = fetch_benchmark_runs_categories(benchmark_runs)
    commits_sha1s ||= ['Commit SHA1']

    graph_data = generate_graph_data(benchmark_runs, @form_result_types) do |benchmark_run|
      commits_sha1s << "
        Commit: #{benchmark_run.initiator.sha1[0..6]}<br>
        Commit Date: #{benchmark_run.initiator.created_at}
      ".squish
    end

    @graphs_columns = build_graphs_columns(commits_sha1s, graph_data)
  end

  def show_releases
    organization = find_organization_by_name(params[:organization_name])
    @repo = find_organization_repos_by_name(organization, params[:repo_name])
    releases = @repo.releases
    @form_result_types = sort_form_result_types(params[:result_types])
    benchmark_runs = fetch_benchmark_runs(releases, 'Release')
    @result_types = fetch_benchmark_runs_categories(benchmark_runs)
    release_versions ||= ['Ruby Version'].concat(releases.pluck(:version))
    graph_data = generate_graph_data(benchmark_runs, @form_result_types)
    @graphs_columns = build_graphs_columns(release_versions, graph_data)
  end

  private

  def generate_graph_data(benchmark_runs, form_result_types)
    graph_data ||= {}

    benchmark_runs.where(category: @form_result_types).each do |benchmark_run|
      benchmark_run.result.each do |key, value|
        yield(benchmark_run) if block_given?

        graph_data[benchmark_run.category] ||= {}
        graph_data[benchmark_run.category][:unit] ||= benchmark_run.unit
        graph_data[benchmark_run.category][:script_url] ||= benchmark_run.script_url
        graph_data[benchmark_run.category][:category] ||= benchmark_run.category
        graph_data[benchmark_run.category][key] ||= [key]
        graph_data[benchmark_run.category][key] << value
      end
    end

    graph_data
  end

  def build_graphs_columns(commits_sha1s, commits_data)
    if !commits_data.empty?
      commits_data.map do |result_type, result_data|
        graphs_columns = [commits_sha1s]

        result_data.map do |_, value|
          graphs_columns << value
        end

        graphs_columns
      end
    end
  end

  def find_organization_by_name(name)
    Organization.find_by_name(params[:organization_name]) || not_found
  end

  def find_organization_repos_by_name(organization, name)
    organization.repos.find_by_name(name)
  end

  def sort_form_result_types(result_types)
    result_types.try(:sort)
  end

  def fetch_benchmark_runs(initiators, initiator_type)
    BenchmarkRun.where(
      initiator_id: initiators.map(&:id),
      initiator_type: initiator_type
    ).preload(:initiator)
  end

  def fetch_benchmark_runs_categories(benchmark_runs)
    benchmark_runs.pluck(:category).uniq.sort.group_by do |category|
      category =~ /\A([^_]+)_/
      $1
    end
  end
end
