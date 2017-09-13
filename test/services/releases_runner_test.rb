require 'test_helper'

class ReleasesRunnerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @repo = create(:repo, name: 'rails')
  end

  test '#run release versions' do
    versions = ['4.10.0', '5.1.3', '5.0.3']

    ReleasesRunner.run(versions, @repo)

    versions.each do |version|
      release = Release.find_by!(version: version, repo_id: @repo.id)
      assert_equal version, release.version
      assert_equal @repo.id, release.repo_id
    end

    assert_enqueued_jobs(versions.count)
  end
end
