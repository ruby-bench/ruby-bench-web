require 'test_helper'

class RunUserBenchTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test '#perform fetches commits and stores them in the db and runs benchmark for each commit' do
    Commit.destroy_all
    assert_enqueued_jobs(134, only: RemoteServerJob) do
      VCR.use_cassette("github ruby 2019-07-02T06:02:16Z") do
        RunUserBench.new.perform("user_benchmark", "http://github.com", "2019-07-02T06:02:16Z", "fe0ddf0e58e65ab3ae3d6e73382c3bebcd4541e5")
      end
    end

    shas = Commit.pluck(:sha1)
    assert_includes shas, "fe0ddf0e58e65ab3ae3d6e73382c3bebcd4541e5"
    assert_includes shas, "6ffef8d459e6423bf4fe35cccb24345bad862448"

    # 134 is the number of commits between the above 2 shas
    # in the ruby repo excluding "ci skip" commits etc.
    assert_equal shas.size, 134
  end
end
