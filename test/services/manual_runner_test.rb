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

  test 'run_last' do
    organization = create(:organization, name: 'jeremyevans')
    repo = create(:repo, name: 'sequel', organization: organization)

    CommitsRunner.expects(:run).times(2).with do |commits|
      commits.each do |commit|
        assert commit[:sha]
        assert commit[:message]
        assert commit[:url]
        assert commit[:created_at]
        assert commit[:repo]
        assert commit[:author_name]
      end
    end

    VCR.use_cassette('github') do
      ManualRunner.new(repo).run_last(200)
    end
  end
end
