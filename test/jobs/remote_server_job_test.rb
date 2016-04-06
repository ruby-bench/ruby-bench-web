require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)
  end

  test "#perform ruby_trunk" do
    [
      'tsp docker pull rubybench/ruby_trunk',
      "tsp docker run --rm
        -e \"RUBY_BENCHMARKS=true\"
        -e \"RUBY_MEMORY_BENCHMARKS=false\"
        -e \"RUBY_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"INCLUDE_PATTERNS=bm_app_answer,bm_abc\"
        rubybench/ruby_trunk".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform(
      'commit_hash', 'ruby_trunk',
      {
        ruby_benchmarks: true, ruby_memory_benchmarks: false,
        include_patterns: 'bm_app_answer,bm_abc'
      }
    )
  end

  test "#perform ruby_releases" do
    [
      'tsp docker pull rubybench/ruby_releases',
      "tsp docker run --rm
        -e \"RUBY_BENCHMARKS=true\"
        -e \"RUBY_MEMORY_BENCHMARKS=false\"
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"INCLUDE_PATTERNS=bm_app_answer,bm_abc\"
        rubybench/ruby_releases".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform(
      '2.2.0', 'ruby_releases',
      {
        ruby_benchmarks: true, ruby_memory_benchmarks: false,
        include_patterns: 'bm_app_answer,bm_abc'
      }
    )
  end

  test "#perform ruby_releases_discourse" do
    [
      "tsp docker pull rubybench/ruby_releases_discourse",
      "tsp docker run --name discourse_redis -d redis:2.8.19",
      "tsp docker run --name discourse_postgres -d postgres:9.3.5",
      "tsp docker run --rm
        --link discourse_postgres:postgres
        --link discourse_redis:redis
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        rubybench/ruby_releases_discourse".squish,
      "tsp docker stop discourse_postgres discourse_redis",
      "tsp docker rm -v discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases_discourse')
  end

  test "#perform ruby_trunk_discourse" do
    [
      "tsp docker pull rubybench/ruby_trunk_discourse",
      "tsp docker run --name discourse_redis -d redis:2.8.19",
      "tsp docker run --name discourse_postgres -d postgres:9.3.5",
      "tsp docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        rubybench/ruby_trunk_discourse".squish,
      "tsp docker stop discourse_postgres discourse_redis",
      "tsp docker rm -v discourse_postgres discourse_redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'ruby_trunk_discourse')
  end

  test "#perform rails_releases" do
    [
      "tsp docker pull rubybench/rails_releases",
      "tsp docker run --name postgres -d postgres:9.3.5",
      "tsp docker run --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -d mysql:5.6.24",
      "tsp docker run --name redis -d redis:2.8.19",
      "tsp docker run --rm
        --link postgres:postgres
        --link mysql:mysql
        --link redis:redis
        -e \"RAILS_VERSION=4.2.6\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"MYSQL2_PREPARED_STATEMENTS=1\"
        -e \"INCLUDE_PATTERNS=bm_activerecord_scope\"
        rubybench/rails_releases".squish,
      "tsp docker stop postgres mysql redis",
      "tsp docker rm -v postgres mysql redis",
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform(
      '4.2.6', 'rails_releases', include_patterns: "bm_activerecord_scope"
    )

    [
      "tsp docker pull rubybench/rails_releases",
      "tsp docker run --name postgres -d postgres:9.3.5",
      "tsp docker run --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -d mysql:5.6.24",
      "tsp docker run --name redis -d redis:2.8.19",
      "tsp docker run --rm
        --link postgres:postgres
        --link mysql:mysql
        --link redis:redis
        -e \"RAILS_VERSION=4.0.0\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"INCLUDE_PATTERNS=\"
        rubybench/rails_releases".squish,
      "tsp docker stop postgres mysql redis",
      "tsp docker rm -v postgres mysql redis",
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('4.0.0', 'rails_releases')
  end

  test "#perform rails_trunk" do
    [
      "tsp docker pull rubybench/rails_trunk",
      "tsp docker run --name postgres -d postgres:9.3.5",
      "tsp docker run --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -d mysql:5.6.24",
      "tsp docker run --name redis -d redis:2.8.19",
      "tsp docker run --rm
        --link postgres:postgres
        --link mysql:mysql
        --link redis:redis
        -e \"RAILS_COMMIT_HASH=1234\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"MYSQL2_PREPARED_STATEMENTS=1\"
        -e \"INCLUDE_PATTERNS=bm_activerecord_scope\"
        rubybench/rails_trunk".squish,
      "tsp docker stop postgres mysql redis",
      "tsp docker rm -v postgres mysql redis"
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform(
      '1234', 'rails_trunk', { include_patterns: 'bm_activerecord_scope' }
    )
  end

  test "#perform bundler_releases" do
    [
      "tsp docker pull rubybench/bundler_releases",
      "tsp docker run --rm
        -e \"BUNDLER_VERSION=1.10.6\"
        -e \"API_NAME=#{Rails.application.secrets.api_name}\"
        -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
        -e \"INCLUDE_PATTERNS=bm_something\"
        rubybench/bundler_releases".squish
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform(
      '1.10.6', 'bundler_releases',
      {
        include_patterns: 'bm_something'
      }
    )
  end

end
