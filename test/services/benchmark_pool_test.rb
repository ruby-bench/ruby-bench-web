require 'test_helper'

class BenchmarkPoolTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#enqueue for ruby' do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:commit, 'abc', 'ruby')
    end

    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:release, 'abc', 'ruby')
    end

    assert_enqueued_jobs 2
  end

  test '#enqueue for rails' do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:commit, 'abc', 'rails')
    end

    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:release, 'abc', 'rails')
    end

    assert_enqueued_jobs 2
  end

  test '#enqueue for sequel' do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:commit, 'abc', 'sequel')
    end

    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:release, 'abc', 'sequel')
    end

    assert_enqueued_jobs 2
  end

  test '#enqueue for ruby-pg' do
    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:commit, 'abc', 'ruby-pg')
    end

    assert_enqueued_with(job: RemoteServerJob) do
      BenchmarkPool.enqueue(:release, 'abc', 'ruby-pg')
    end

    assert_enqueued_jobs 2
  end
end
