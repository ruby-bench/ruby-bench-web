require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(ssh)
    ssh.expects(:exec!)
  end

  test "#perform rails command" do
    RemoteServerJob.any_instance
      .expects(:rails_command)
      .returns(
        "sudo docker pull tgxworld/rails_bench && sudo docker run --rm -e
        \"RAILS_COMMIT_HASH=commit_hash\" -e \"RUBY_VERSION=2.1.5\" -e
        \"KO1TEST_SEED_CNT=100\" tgxworld/rails_bench".squish
      )

    RemoteServerJob.new.perform('commit_hash', 'rails')
  end

  test "#perform ruby command" do
    RemoteServerJob.any_instance
      .expects(:ruby_command)
      .returns(
        "sudo docker pull tgxworld/ruby_bench && sudo docker run --rm -e
        \"RUBY_COMMIT_HASH=commit_hash\" tgxworld/ruby_bench".squish
      )

    RemoteServerJob.new.perform('commit_hash', 'ruby')
  end
end
