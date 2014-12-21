require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(ssh)
    ssh.expects(:exec!)
  end

  test "#perform ruby_bench" do
    RemoteServerJob.any_instance
      .expects(:ruby_bench)
      .returns(
        "sudo docker pull tgxworld/ruby_bench && sudo docker run --rm -e
        \"RUBY_COMMIT_HASH=commit_hash\" tgxworld/ruby_bench".squish
      )

    RemoteServerJob.new.perform('commit_hash', 'ruby_bench')
  end
end
