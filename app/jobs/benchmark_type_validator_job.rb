class BenchmarkTypeValidatorJob < ApplicationJob
  queue_as :default

  def perform(benchmark_type)
    benchmark_script = Net::HTTP.get(URI.parse(benchmark_type.script_url))
    digest = Digest::SHA1.hexdigest(benchmark_script)

    if digest != benchmark_type.digest
      benchmark_type.benchmark_runs.update_all(validity: false)
      benchmark_type.digest = digest
      benchmark_type.save!
    end
  end
end
