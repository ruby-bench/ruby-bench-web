require 'test_helper'

class ManualRunTest < ActionDispatch::IntegrationTest
  def test_running_commits_manually
    @repo = create(:repo)
    pattern = 'bm_test,bm_array'

    ManualRunner.any_instance.expects(:run_last).with(100, pattern: pattern)

    post(admin_run_commits_path(@repo.name), params: { count: 100, pattern: pattern })
  end
end
