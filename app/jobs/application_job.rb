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
      @heroku_worker_manager.set_worker(0) if teardown_worker?
    end
  end

  def teardown_worker?
    # For some reason, jobs might be left stranded with Heroku causing this
    # condition to fail and not do its job. Investigate further and fix.
    (Delayed::Job.count == 1) && Delayed::Job.first.failed_at.nil?
  end

  def production?
    yield if Rails.env.production?
  end
end
