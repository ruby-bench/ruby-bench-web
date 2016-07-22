class SparklineDataJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(25) }

  def perform
    Repo.all.each { |repo| repo.generate_sparkline_data }
  end
end
