require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)
  end

  test "#perform ruby_bench" do
    [
      'tsp docker pull tgxworld/ruby_bench',
      "tsp docker run --rm
        -e \"RUBY_BENCHMARKS=true\"
        -e \"RUBY_MEMORY_BENCHMARKS=false\"
        -e \"RUBY_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/ruby_bench".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'ruby_bench')
  end

  test "#perform ruby_releases" do
    [
      'tsp docker pull tgxworld/ruby_releases',
      "tsp docker run --rm
        -e \"RUBY_BENCHMARKS=true\"
        -e \"RUBY_MEMORY_BENCHMARKS=false\"
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/ruby_releases".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases')
  end

  test "#perform ruby_releases_memory" do
    [
      "tsp docker pull tgxworld/ruby_releases",
      "tsp docker run --rm
        -e \"RUBY_BENCHMARKS=false\"
        -e \"RUBY_MEMORY_BENCHMARKS=true\"
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/ruby_releases".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases_memory')
  end

  test "#perform ruby_releases_discourse" do
    [
      "tsp docker pull tgxworld/ruby_releases_discourse",
      "tsp docker run --name discourse_redis -d redis:2.8.19",
      "tsp docker run --name discourse_postgres -d postgres:9.3.5",
      "tsp docker run --rm
        --link discourse_postgres:postgres
        --link discourse_redis:redis
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/ruby_releases_discourse".squish,
      "tsp docker stop discourse_postgres discourse_redis",
      "tsp docker rm discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases_discourse')
  end

  test "#perform discourse_rails_head_bench" do
    [
      "tsp docker pull tgxworld/discourse_rails_head_bench",
      "tsp docker run --name discourse_redis -d redis:2.8.19",
      "tsp docker run --name discourse_postgres -d postgres:9.3.5",
      "tsp docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RAILS_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/discourse_rails_head_bench".squish,
      "tsp docker stop discourse_postgres discourse_redis",
      "tsp docker rm discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'discourse_rails_head_bench')
  end

  test "#perform ruby_bench_discourse" do
    [
      "tsp docker pull tgxworld/ruby_bench_discourse",
      "tsp docker run --name discourse_redis -d redis:2.8.19",
      "tsp docker run --name discourse_postgres -d postgres:9.3.5",
      "tsp docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        tgxworld/ruby_bench_discourse".squish,
      "tsp docker stop discourse_postgres discourse_redis",
      "tsp docker rm discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'ruby_bench_discourse')
  end
end
