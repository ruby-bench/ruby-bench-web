require 'test_helper'

class ManualRunTest < ActionDispatch::IntegrationTest
  def test_running_commits_manually
    @repo = create(:repo)

    ManualRunner.any_instance.expects(:run_last).with(100)

    post(admin_repo_run_path(@repo.name), params: { count: 100 })
  end
end
