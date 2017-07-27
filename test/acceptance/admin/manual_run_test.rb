require 'acceptance/test_helper'

class RunningSuiteManuallyTest < AcceptanceTest
  test 'Admin should be able to manually run suite for existing repo' do
    repo = create(:repo)

    visit admin_repo_path(repo.name)
    assert page.has_css?('label', text: I18n.t('admin.manual_run_count_label'))
    assert page.has_css?('label', text: I18n.t('admin.manual_run_pattern_label'))
    assert page.has_css?('button', text: I18n.t('admin.manual_run_button'))
  end
end
