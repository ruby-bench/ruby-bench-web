class ReposController < ApplicationController
  # ZOMG too much logic here.
  # TODO: Refactor and add tests.
  def show
    @repo = Repo.find_by(name: params[:repo_name])
    @commits = @repo.commits
    @result_type = params[:result_type]

    commits_sha1s = ['Commit SHA1']
    commits_data = {}

    @commits.includes(:benchmark_runs).reverse.each do |commit|
      commit_benchmark_runs = commit.benchmark_runs
      next if commit_benchmark_runs.empty?

      if !@result_types
        @result_types = commit_benchmark_runs.map(&:category)
        @result_types.uniq
      end

      @result_type ||= commit.benchmark_runs.first.category

      commit.benchmark_runs.where(category: @result_type).each do |benchmark_run|
        commits_sha1s << commit.sha1[0..4]

        benchmark_run.result.each do |key, value|
          commits_data[key] ||= [key]
          commits_data[key] << value
        end
      end
    end

    @columns = [commits_sha1s]

    commits_data.each do |_, value|
      @columns << value
    end
  end
end
