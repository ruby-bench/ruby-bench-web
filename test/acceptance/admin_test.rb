require 'acceptance/test_helper'

class AdminTest < AcceptanceTest
  test 'Admin should be able to manually run suite for existing repo' do
    repo = create(:repo)

    visit admin_repo_path(repo.name)
    page.must_have_content 'Run last'
  end
end
