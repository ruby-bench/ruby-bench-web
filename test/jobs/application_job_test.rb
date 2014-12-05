require 'test_helper'

class ApplicationJobTest < ActiveJob::TestCase
  test 'workers are automatically setup and teardown' do
    Rails.env.stubs(:production?).returns(:true)
    ApplicationJob.any_instance.stubs(:teardown_worker?).returns(true)
    ApplicationJob.any_instance.stubs(:perform)

    heroku_worker_manager = mock('heroku_worker_manager')
    HerokuWorkerManager.stubs(:new).returns(heroku_worker_manager)

    heroku_worker_manager.expects(:set_worker).with(1)
    heroku_worker_manager.expects(:set_worker).with(0)

    ApplicationJob.perform_now
  end
end

