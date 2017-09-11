class Admin::ReposController < AdminController
  before_action :set_repo

  def show
  end

  def run_commits
    ManualRunner.new(@repo).run_last(
      params[:count].to_i,
      pattern: params[:pattern] == 'all' ? '' : params[:pattern]
    )

    redirect_to admin_repo_path(@repo.name), notice: "#{@repo.name.capitalize} suite is running for last #{params[:count].to_i} commits."
  end

  private

  def set_repo
    @repo = Repo.find_by(name: params[:repo_name])
  end
end
