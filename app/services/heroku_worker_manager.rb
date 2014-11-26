require 'platform-api'

class HerokuWorkerManager
  attr_reader :client

  def initialize
    @client = PlatformAPI.connect(Rails.application.secrets.heroku_api_key)
  end

  def set_worker(count)
    @client.formation.update('railsbench', 'worker', { "quantity" => "#{count}" })
  end
end
