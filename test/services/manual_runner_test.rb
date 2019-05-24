require 'test_helper'

class ManualRunnerTest < ActiveSupport::TestCase
  setup do
    organization = create(:organization, name: 'jeremyevans')
    @repo = create(:repo, name: 'sequel', organization: organization)
  end

  test 'new with existing repo' do
    assert_nothing_raised do
      ManualRunner.new(create(:repo))
    end
  end

  test 'new with non existing repo' do
    assert_raises do
      ManualRunner.new(build(:repo))
    end
  end

  test 'run last 200 commits' do
    expect_to_run count: 200, times: 1

    VCR.use_cassette('github 200 commits') do
      ManualRunner.new(@repo).run_last(200)
    end
  end

  test 'run last 20 commits' do
    expect_to_run count: 20, times: 1

    VCR.use_cassette('github 20 commits') do
      ManualRunner.new(@repo).run_last(20)
    end
  end

  test 'run releases' do
    ReleasesRunner.expects(:run).with do |versions|
      assert_equal ['4.0.0', '5.0.0'], versions
    end

    ManualRunner.new(@repo).run_releases(['4.0.0', '5.0.0'])
  end

  private

  def expect_to_run(count:, times:)
    CommitsRunner.expects(:run).times(times).returns(count).with do |source, commits, repo, pattern|
      commits.each do |commit|
        assert commit['sha']
        assert commit['commit']['message']
        assert commit['html_url']
        assert commit['commit']['author']['date']
        assert commit['commit']['author']['name']
        assert repo
        assert_equal '', pattern
        assert_equal :api, source
      end

      assert_equal count, commits.count
    end
  end
end
