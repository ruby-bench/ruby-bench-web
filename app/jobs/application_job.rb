class ApplicationJob < ActiveJob::Base
  after_perform :teardown_worker

  def initialize(*arguments)
    super

    production? do
      @heroku_worker_manager = HerokuWorkerManager.new
      @heroku_worker_manager.set_worker(1)
    end
  end

  private

  def teardown_worker
    production? do
      @heroku_worker_manager.set_worker(0) if (job_count == 0)
    end
  end

  def job_count
    Delayed::Job.where(failed_at: nil).count
  end

  def production?
    yield if Rails.env.production?
  end
end
