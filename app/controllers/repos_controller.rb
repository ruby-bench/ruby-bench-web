class ReposController < ApplicationController
  def index
    @repos = Repo.all
  end

  def show
    @repo = Repo.find(params[:id])
    @commits = @repo.commits
  end
end
