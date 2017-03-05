require 'test_helper'

class BenchmarkPoolTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#enqueue for ruby" do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue('ruby', 'abc')
    end

    assert_enqueued_jobs 1
  end

  test "#enqueue for rails" do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue('rails', 'abc')
    end

    assert_enqueued_jobs 1
  end

  test "#enqueue for sequel" do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue('sequel', 'abc')
    end

    assert_enqueued_jobs 1
  end
end
