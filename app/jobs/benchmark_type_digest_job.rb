class BenchmarkTypeDigestJob < ApplicationJob
  queue_as :default

  def perform(benchmark_type)
    benchmark_script = Net::HTTP.get(URI.parse(benchmark_type.script_url))
    benchmark_type.digest = Digest::SHA1.hexdigest(benchmark_script)
    benchmark_type.save!
  end
end
