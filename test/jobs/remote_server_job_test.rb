require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)
  end

  test "#perform ruby_bench" do
    [
      'docker pull tgxworld/ruby_bench',
      "docker run --rm -e \"RUBY_COMMIT_HASH=commit_hash\" tgxworld/ruby_bench"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'ruby_bench')
  end

  test "#perform discourse_rails_head_bench" do
    [
      "docker pull tgxworld/discourse_rails_head_bench",
      "docker run --name discourse_redis -d redis:latest && docker
        run --name discourse_postgres -d postgres:latest".squish,
      "docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RAILS_COMMIT_HASH=commit_hash\"
        tgxworld/discourse_rails_head_bench".squish,
      "docker stop discourse_postgres discourse_redis",
      "docker rm discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'discourse_rails_head_bench')
  end

  test "#perform discourse_ruby_trunk_bench" do
    [
      "docker pull tgxworld/discourse_ruby_trunk_bench",
      "docker run --name discourse_redis -d redis:latest && docker
        run --name discourse_postgres -d postgres:latest".squish,
      "docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=commit_hash\"
        tgxworld/discourse_rails_head_bench".squish,
      "docker stop discourse_postgres discourse_redis",
      "docker rm discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'discourse_ruby_trunk_bench')
  end
end
