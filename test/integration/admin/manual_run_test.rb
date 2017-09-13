require 'test_helper'

class ManualRunTest < ActionDispatch::IntegrationTest
  setup do
    @repo = create(:repo)
    @pattern = 'bm_test,bm_array'
  end

  test 'test_running_commits_manually' do
    ManualRunner.any_instance.expects(:run_last).with(100, pattern: @pattern)

    post(admin_run_commits_path(@repo.name), params: { count: 100, pattern: @pattern })
  end

  test 'test_running_releases_manually' do
    ManualRunner.any_instance.expects(:run_releases).with(['1.0.0', '2.0.0', '3.0.0'], pattern: @pattern)

    post(admin_run_releases_path(@repo.name), params: { versions: '1.0.0,2.0.0,3.0.0', pattern: @pattern })
  end
end
