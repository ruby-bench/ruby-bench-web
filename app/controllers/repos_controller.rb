class ReposController < ApplicationController
  def index
    @repos = Repo.all
  end

  def show
    @repo = Repo.find(params[:id])
    @commits = @repo.commits

    @commits_sha1s = []
    @commits_data = {}

    @commits.includes(:benchmark_runs).each do |commit|
      if commit_benchmark_run = commit.benchmark_runs.first
        @commits_sha1s << commit.sha1[0..4]

        commit_benchmark_run.result.each do |key, value|
          @commits_data[key] ||= [key]
          @commits_data[key] << value
        end
      end
    end
  end
end
