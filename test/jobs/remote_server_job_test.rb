require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  test 'SSH connection is made to server' do
    Net::SSH.expects(:start).once
    RemoteServerJob.perform_now('abcde')
  end
end
