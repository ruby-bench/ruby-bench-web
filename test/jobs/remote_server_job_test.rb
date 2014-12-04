require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  test 'workers are automatically setup and teardown' do
    Rails.env.stubs(:production?).returns(:true)
    Net::SSH.stubs(:start)
    RemoteServerJob.any_instance.stubs(:teardown_worker?).returns(true)

    heroku_worker_manager = mock('heroku_worker_manager')
    HerokuWorkerManager.stubs(:new).returns(heroku_worker_manager)

    heroku_worker_manager.expects(:set_worker).with(1)
    heroku_worker_manager.expects(:set_worker).with(0)

    RemoteServerJob.perform_now('abcde')
  end
end
