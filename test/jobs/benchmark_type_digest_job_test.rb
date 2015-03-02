require 'test_helper'

class BenchmarkTypeDigestJobTest < ActiveJob::TestCase
  setup do
    @benchmark_type = benchmark_types(:array_count)
    @mock_benchmark_script = "Array.new"
    Net::HTTP.stubs(:get).returns(@mock_benchmark_script)
  end

  test '#perform' do
    digest = Digest::SHA1.hexdigest(@mock_benchmark_script)

    assert @benchmark_type.digest.blank?

    BenchmarkTypeDigestJob.new.perform(@benchmark_type)
    assert digest, @benchmark_type.digest
  end
end
