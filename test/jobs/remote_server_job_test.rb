require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)

    set_script_arguments
  end

  test '#perform ruby_trunk' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::RUBY_TRUNK} #{@ruby} #{@memory} #{@optcarrot} #{@liquid} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'ruby_trunk', include_patterns: @patterns
    )
  end

  test '#perform ruby_releases' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::RUBY_RELEASE} #{@ruby} #{@memory} #{@optcarrot} #{@liquid} #{@version} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'ruby_releases', include_patterns: @patterns
    )
  end

  test '#perform ruby_releases_discourse' do
    [
      'tsp docker pull rubybench/ruby_releases_discourse',
      'tsp docker run --name discourse_redis -d redis:2.8.19',
      'tsp docker run --name discourse_postgres -d postgres:9.3.5',
      "tsp docker run --rm
        --link discourse_postgres:postgres
        --link discourse_redis:redis
        -e \"RUBY_VERSION=2.2.0\"
        -e \"API_NAME=#{@api_name}\"
        -e \"API_PASSWORD=#{@api_password}\"
        rubybench/ruby_releases_discourse".squish,
      'tsp docker stop discourse_postgres discourse_redis',
      'tsp docker rm -v discourse_postgres discourse_redis'
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('2.2.0', 'ruby_releases_discourse')
  end

  test '#perform ruby_trunk_discourse' do
    [
      'tsp docker pull rubybench/ruby_trunk_discourse',
      'tsp docker run --name discourse_redis -d redis:2.8.19',
      'tsp docker run --name discourse_postgres -d postgres:9.3.5',
      "tsp docker run --rm --link discourse_postgres:postgres
        --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=commit_hash\"
        -e \"API_NAME=#{@api_name}\"
        -e \"API_PASSWORD=#{@api_password}\"
        rubybench/ruby_trunk_discourse".squish,
      'tsp docker stop discourse_postgres discourse_redis',
      'tsp docker rm -v discourse_postgres discourse_redis'
    ].each do |command|

      @ssh.expects(:exec!).with(command)
    end

    RemoteServerJob.new.perform('commit_hash', 'ruby_trunk_discourse')
  end

  test '#perform rails_releases' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::RAILS_RELEASE} #{@version} #{@api_name} #{@api_password} 0 #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'rails_releases', include_patterns: @patterns
    )
  end

  test '#perform rails_trunk' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::RAILS_MASTER} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'rails_trunk', include_patterns: @patterns
    )
  end

  test '#perform sequel_releases' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::SEQUEL_RELEASE} #{@version} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'sequel_releases', include_patterns: @patterns
    )
  end

  test '#perform sequel_trunk' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::SEQUEL_MASTER} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'sequel_trunk', include_patterns: @patterns
    )
  end

  test '#perform bundler_releases' do
    @ssh.expects(:exec!).with(
      "tsp #{RemoteServerJob::BUNDLER_RELEASE} #{@version} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'bundler_releases', include_patterns: @patterns
    )
  end

  private

  def set_script_arguments
    @api_name = Rails.application.secrets.api_name
    @api_password = Rails.application.secrets.api_password
    @patterns = 'bm_app_answer,bm_abc'
    @commit_hash = '12345'
    @version = '3.4.5'

    ruby
    rails
  end

  def ruby
    @ruby = true
    @memory = true
    @optcarrot = true
    @liquid = true
  end

  def rails
    @prepared_statements = 1
  end
end
