class Admin::ReposController < AdminController
  before_action :set_repo

  def show
  end

  def run_commits
    ManualRunner.new(@repo).run_last(
      commits_count,
      pattern: pattern
    )

    redirect_to admin_repo_path(@repo.name), notice: "#{@repo.name.capitalize} suite is running for last #{params[:count].to_i} commits."
  end

  def run_releases
    unless versions.empty?
      ManualRunner.new(@repo).run_releases(
        versions,
        pattern: pattern
      )
      redirect_to admin_repo_path(@repo.name), notice: "#{@repo.name.capitalize} suite is running for selected versions."
    else
      redirect_to admin_repo_path(@repo.name), notice: 'You need to select release versions you want to run.'
    end
  end

  private

  def set_repo
    @repo = Repo.find_by(name: params[:repo_name])
  end

  def versions
    params[:versions].split(',')
  end

  def pattern
    params[:pattern] == 'all' ? '' : params[:pattern]
  end

  def commits_count
    params[:count].to_i
  end
end
