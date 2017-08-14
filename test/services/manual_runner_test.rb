require 'test_helper'

class ManualRunnerTest < ActiveSupport::TestCase
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
    organization = create(:organization, name: 'jeremyevans')
    repo = create(:repo, name: 'sequel', organization: organization)

    CommitsRunner.expects(:run).times(2).returns(100).with do |commits|
      commits.each do |commit|
        assert commit[:sha]
        assert commit[:message]
        assert commit[:url]
        assert commit[:created_at]
        assert commit[:repo]
        assert commit[:author_name]
      end

      assert 100, commits.count
    end

    VCR.use_cassette('github 200 commits') do
      ManualRunner.new(repo).run_last(200)
    end
  end

  test 'run last 20 commits' do
    organization = create(:organization, name: 'jeremyevans')
    repo = create(:repo, name: 'sequel', organization: organization)

    CommitsRunner.expects(:run).times(1).returns(20).with do |commits|
      commits.each do |commit|
        assert commit[:sha]
        assert commit[:message]
        assert commit[:url]
        assert commit[:created_at]
        assert commit[:repo]
        assert commit[:author_name]
      end

      assert_equal 20, commits.count
    end

    VCR.use_cassette('github 20 commits') do
      ManualRunner.new(repo).run_last(20)
    end
  end
end
