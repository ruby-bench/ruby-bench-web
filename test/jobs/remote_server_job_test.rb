require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)
  end

  test "#perform ruby_bench" do
    @ssh.expects(:exec!).with('docker pull tgxworld/ruby_bench')

    @ssh.expects(:exec!).with(
      "docker run --rm -e \"RUBY_COMMIT_HASH=commit_hash\" tgxworld/ruby_bench"
    )

    RemoteServerJob.new.perform('commit_hash', 'ruby_bench')
  end
end
