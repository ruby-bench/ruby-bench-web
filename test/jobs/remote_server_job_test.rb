require 'test_helper'

class RemoteServerJobTest < ActiveJob::TestCase
  setup do
    @ssh = mock('ssh')
    Net::SSH.stubs(:start).yields(@ssh)

    set_script_arguments
  end

  test "#perform ruby_trunk" do
    @ssh.expects(:exec!).with(
      "tsp #{@ruby_trunk_script} #{@ruby} #{@memory} #{@optcarrot} #{@liquid} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'ruby_trunk',
      {
        include_patterns: @patterns
      }
    )
  end

  test "#perform ruby_releases" do
    @ssh.expects(:exec!).with(
      "tsp #{@ruby_release_script} #{@ruby} #{@memory} #{@optcarrot} #{@liquid} #{@version} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'ruby_releases',
      {
        include_patterns: @patterns
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
    @ssh.expects(:exec!).with(
      "tsp #{@rails_release_script} #{@version} #{@api_name} #{@api_password} 0 #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'rails_releases', include_patterns: @patterns
    )
  end

  test "#perform rails_trunk" do
    @ssh.expects(:exec!).with(
      "tsp #{@rails_master_script} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'rails_trunk', include_patterns: @patterns
    )
  end

  test "#perform sequel_releases" do
    @ssh.expects(:exec!).with(
      "tsp #{@sequel_release_script} #{@version} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @version, 'sequel_releases', include_patterns: @patterns
    )
  end

  test "#perform sequel_trunk" do
    @ssh.expects(:exec!).with(
      "tsp #{@sequel_master_script} #{@commit_hash} #{@api_name} #{@api_password} #{@patterns}"
    )

    RemoteServerJob.new.perform(
      @commit_hash, 'sequel_trunk', include_patterns: @patterns
    )
  end

  test "#perform bundler_releases" do
    @ssh.expects(:exec!).with(
      "tsp #{@bundler_release_script} #{@version} #{@api_name} #{@api_password} #{@patterns}"
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
    bundler
    sequel
  end

  def ruby
    @ruby = true
    @memory = true
    @optcarrot = true
    @liquid = true
    @ruby_trunk_script = RemoteServerJob::RUBY_TRUNK
    @ruby_release_script = RemoteServerJob::RUBY_RELEASE
  end

  def rails
    @rails_master_script = RemoteServerJob::RAILS_MASTER
    @rails_release_script = RemoteServerJob::RAILS_RELEASE
    @prepared_statements = 1
  end

  def bundler
    @bundler_release_script = RemoteServerJob::BUNDLER_RELEASE
  end

  def sequel
    @sequel_master_script = RemoteServerJob::SEQUEL_MASTER
    @sequel_release_script = RemoteServerJob::SEQUEL_RELEASE
  end
end
