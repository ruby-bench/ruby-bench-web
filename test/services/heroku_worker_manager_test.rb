require 'test_helper'

class HerokuWorkerManagerTest < ActiveSupport::TestCase
  test "#set_worker" do
    PlatformAPI.expects(:connect).returns(mock('client'))
    heroku_worker_manager = HerokuWorkerManager.new
    client = heroku_worker_manager.client

    formation = mock('formation')
    client.expects(:formation).returns(formation)
    formation.expects(:update).with('rubybench', 'worker', { "quantity" => "1" })
    heroku_worker_manager.set_worker(1)

    formation = mock('formation')
    client.expects(:formation).returns(formation)
    formation.expects(:update).with('rubybench', 'worker', { "quantity" => "0" })
    heroku_worker_manager.set_worker(0)
  end
end
