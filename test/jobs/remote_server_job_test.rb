require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)
  end

  test "#perform ruby_trunk" do
    command =
      [
        'docker pull rubybench/ruby_trunk',
        "docker run --rm
          -e \"RUBY_BENCHMARKS=true\"
          -e \"RUBY_MEMORY_BENCHMARKS=false\"
          -e \"RUBY_COMMIT_HASH=commit_hash\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          -e \"INCLUDE_PATTERNS=bm_app_answer,bm_abc\"
          rubybench/ruby_trunk".squish
      ].join(RemoteServerJob::COMMAND_CHAIN)

    @ssh.expects(:exec!).with("tsp '#{command}'")

    RemoteServerJob.new.perform(
      'commit_hash', 'ruby_trunk',
      {
        ruby_benchmarks: true, ruby_memory_benchmarks: false,
        include_patterns: 'bm_app_answer,bm_abc'
      }
    )
  end

  test "#perform ruby_releases" do
    command =
      [
        'docker pull rubybench/ruby_releases',
        "docker run --rm
          -e \"RUBY_BENCHMARKS=true\"
          -e \"RUBY_MEMORY_BENCHMARKS=false\"
          -e \"RUBY_VERSION=2.2.0\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          -e \"INCLUDE_PATTERNS=bm_app_answer,bm_abc\"
          rubybench/ruby_releases".squish
      ].join(RemoteServerJob::COMMAND_CHAIN)

    @ssh.expects(:exec!).with("tsp '#{command}'")

    RemoteServerJob.new.perform(
      '2.2.0', 'ruby_releases',
      {
        ruby_benchmarks: true, ruby_memory_benchmarks: false,
        include_patterns: 'bm_app_answer,bm_abc'
      }
    )
  end

  test "#perform ruby_releases_discourse" do
    command =
      [
        "docker pull rubybench/ruby_releases_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm
          --link discourse_postgres:postgres
          --link discourse_redis:redis
          -e \"RUBY_VERSION=2.2.0\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          rubybench/ruby_releases_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm discourse_postgres discourse_redis"
      ].join(RemoteServerJob::COMMAND_CHAIN)

    @ssh.expects(:exec!).with("tsp '#{command}'")

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases_discourse')
  end

  test "#perform ruby_trunk_discourse" do
    command =
      [
        "docker pull rubybench/ruby_trunk_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm --link discourse_postgres:postgres
          --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=commit_hash\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          rubybench/ruby_trunk_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm discourse_postgres discourse_redis"
      ].join(RemoteServerJob::COMMAND_CHAIN)

    @ssh.expects(:exec!).with("tsp '#{command}'")

    RemoteServerJob.new.perform('commit_hash', 'ruby_trunk_discourse')
  end
end
