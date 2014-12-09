class ReposController < ApplicationController
  # ZOMG too much logic here.
  # TODO: Refactor and add tests.
  def show
    @repo = Repo.find_by(name: params[:repo_name])

    @commits = @repo.commits
      .joins(:benchmark_runs)
      .where("(SELECT COUNT(*) FROM commits WHERE benchmark_runs.commit_id=commits.id) != 0")

    @form_result_type = params[:result_type]
    @result_types = @commits.first.benchmark_runs.map(&:category).sort

    form_result_types =
      case @form_result_type
      when 'all'
        @result_types
      when 'none', nil
        []
      else
        [@form_result_type]
      end

    commits_sha1s ||= ['Commit SHA1']
    commits_data ||= {}

    @commits.includes(:benchmark_runs).reverse.each do |commit|
      commit_benchmark_runs = commit.benchmark_runs
      next if commit_benchmark_runs.empty?

      form_result_types.each do |result_type|
        commits_data[result_type] ||= {}

        commit.benchmark_runs.where(category: result_type).each do |benchmark_run|
          commits_sha1s << "
            Commit: #{commit.sha1[0..6]}<br>
            Commit Date: #{commit.created_at}<br>
            Environment: #{benchmark_run.environment}<br>
          ".squish

          benchmark_run.result.each do |key, value|
            commits_data[result_type][key] ||= [key]
            commits_data[result_type][key] << value
          end
        end
      end
    end

    @graphs_columns = build_graphs_columns(commits_sha1s, commits_data)
  end

  private

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
end
