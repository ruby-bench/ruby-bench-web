require 'test_helper'

class BenchmarkTypeValidatorJobTest < ActiveJob::TestCase
  setup do
    @benchmark_type = benchmark_types(:array_count)
    @mock_benchmark_script = "Array.new"
    Net::HTTP.stubs(:get).returns(@mock_benchmark_script)
  end

  test '#perform' do
    digest = Digest::SHA1.hexdigest(@mock_benchmark_script)

    assert @benchmark_type.digest.blank?

    BenchmarkTypeValidatorJob.new.perform(@benchmark_type)
    assert_equal digest, @benchmark_type.digest

    result = @benchmark_type.benchmark_runs.all? do |bm|
      !bm.validity
    end

    assert result
  end
end
