require 'acceptance/test_helper'

class RunningSuiteManuallyTest < AcceptanceTest
  setup do
    @repo = create(:repo)
  end

  test 'Admin should be able to manually run commits and releases for existing repo' do
    visit admin_repo_path(@repo.name)

    assert page.has_css?('label', text: I18n.t('admin.commits_run_count_label'))
    assert page.has_css?('label', text: I18n.t('admin.manual_run_pattern_label'), count: 2)
    assert page.has_css?('button', text: I18n.t('admin.manual_run_button'), count: 2)
    assert page.has_css?('label', text: I18n.t('admin.releases_run_versions_label'))
  end
end
