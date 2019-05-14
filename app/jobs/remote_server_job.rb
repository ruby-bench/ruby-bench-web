require 'net/ssh'

class RemoteServerJob < ActiveJob::Base
  queue_as :default

  SCRIPTS_PATH = './ruby-bench-docker/scripts'

  RUBY_COMMIT = "#{SCRIPTS_PATH}/ruby/trunk.sh"
  RUBY_RELEASE = "#{SCRIPTS_PATH}/ruby/releases.sh"

  RAILS_COMMIT = "#{SCRIPTS_PATH}/rails/master.sh"
  RAILS_RELEASE = "#{SCRIPTS_PATH}/rails/releases.sh"

  SEQUEL_COMMIT = "#{SCRIPTS_PATH}/sequel/master.sh"
  SEQUEL_RELEASE = "#{SCRIPTS_PATH}/sequel/releases.sh"

  BUNDLER_RELEASE = "#{SCRIPTS_PATH}/bundler/releases.sh"

  PG_COMMIT = "#{SCRIPTS_PATH}/pg/master.sh"

  RUBY_COMMIT_DISCOURSE = "#{SCRIPTS_PATH}/ruby/discourse/trunk.sh"

  RUBY_CUSTOM_SCRIPTS = "#{SCRIPTS_PATH}/ruby/custom_scripts/receiver.sh"

  # Use keyword arguments once Rails 4.2.1 has been released.
  def perform(initiator_key, benchmark_group, options = {})
    Net::SSH.start(
      secrets.bare_metal_server_ip,
      secrets.bare_metal_server_user,
      password: secrets.bare_metal_server_password
    ) do |ssh|

      send(benchmark_group, ssh, initiator_key, options)
    end
  end

  private

  def ruby_commit(ssh, commit_hash, options)
    ruby = true
    memory = true
    optcarrot = true
    liquid = false
    patterns = options[:include_patterns]

    ssh_exec!(
      ssh,
      "#{RUBY_COMMIT} #{ruby} #{memory} #{optcarrot} #{liquid} #{commit_hash} #{secrets.api_name} #{secrets.api_password} #{patterns}"
    )
  end

  def ruby_release(ssh, version, options)
    ruby = true
    memory = true
    optcarrot = true
    liquid = true
    patterns = options[:include_patterns]

    ssh_exec!(
      ssh,
      "#{RUBY_RELEASE} #{ruby} #{memory} #{optcarrot} #{liquid} #{version} #{secrets.api_name} #{secrets.api_password} #{patterns}"
    )
  end

  def ruby_custom_scripts(ssh, script_url, options)
    commit_a = options[:commit_a]
    commit_b = options[:commit_b]
    ssh_exec!(
      ssh,
      "#{RUBY_CUSTOM_SCRIPTS} #{script_url} #{commit_a} #{commit_b} #{secrets.api_name} #{secrets.api_password}"
    )
  end

  def ruby_release_discourse(ssh, ruby_version, options)
    execute_ssh_commands(ssh,
      [
        'docker pull rubybench/ruby_releases_discourse',
        'docker run --name discourse_redis -d redis:2.8.19',
        'docker run --name discourse_postgres -d postgres:9.3.5',
        "docker run --rm
          --link discourse_postgres:postgres
          --link discourse_redis:redis
          -e \"RUBY_VERSION=#{ruby_version}\"
          -e \"API_NAME=#{secrets.api_name}\"
          -e \"API_PASSWORD=#{secrets.api_password}\"
          rubybench/ruby_releases_discourse".squish,
        'docker stop discourse_postgres discourse_redis',
        'docker rm -v discourse_postgres discourse_redis'
      ]
    )
  end

  def ruby_commit_discourse(ssh, commit_hash, options)
    ssh_exec!(
      ssh,
      "#{RUBY_COMMIT_DISCOURSE} #{commit_hash} #{secrets.api_name} #{secrets.api_password}"
    )
  end

  def rails_release(ssh, version, options)
    prepared_statements = if version >= '4.2.5' then 1 else 0 end
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{RAILS_RELEASE} #{version} #{secrets.api_name} #{secrets.api_password} #{prepared_statements} #{patterns}")
  end

  def rails_commit(ssh, commit_hash, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{RAILS_COMMIT} #{commit_hash} #{secrets.api_name} #{secrets.api_password} #{patterns}")
  end

  def sequel_release(ssh, version, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{SEQUEL_RELEASE} #{version} #{secrets.api_name} #{secrets.api_password} #{patterns}")
  end

  def sequel_commit(ssh, commit_hash, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{SEQUEL_COMMIT} #{commit_hash} #{secrets.api_name} #{secrets.api_password} #{patterns}")
  end

  def bundler_release(ssh, version, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{BUNDLER_RELEASE} #{version} #{secrets.api_name} #{secrets.api_password} #{patterns}")
  end

  def pg_commit(ssh, commit_hash, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{PG_COMMIT} #{commit_hash} #{secrets.api_name} #{secrets.api_password} #{patterns}")
  end

  def execute_ssh_commands(ssh, commands)
    commands.each do |command|
      ssh_exec!(ssh, command)
    end
  end

  def ssh_exec!(ssh, command)
    ssh.exec!("tsp #{command}") do |channel, stream, data|
      puts data
    end
  end

  def build_include_patterns(patterns)
    "-e \"INCLUDE_PATTERNS=#{patterns}\""
  end

  def secrets
    Rails.application.secrets
  end
end
