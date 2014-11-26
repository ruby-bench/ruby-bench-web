require 'test_helper'

class HerokuWorkerManagerTest < ActiveSupport::TestCase
  test "#set_worker" do
    VCR.use_cassette("#{self.class.name.underscore}/set_worker") do
      heroku_worker_manager = HerokuWorkerManager.new
      client = heroku_worker_manager.client

      heroku_worker_manager.set_worker(1)
      assert_equal(client.formation.info('railsbench', 'worker')["quantity"], 1)

      heroku_worker_manager.set_worker(0)
      assert_equal(client.formation.info('railsbench', 'worker')["quantity"], 0)
    end
  end
end
