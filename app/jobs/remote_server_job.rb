require 'net/ssh'

class RemoteServerJob < ActiveJob::Base
  queue_as :default

  SCRIPTS_PATH = "./ruby-bench-docker/scripts"

  RUBY_TRUNK = "#{SCRIPTS_PATH}/ruby/trunk.sh"
  RUBY_RELEASE = "#{SCRIPTS_PATH}/ruby/releases.sh"

  RAILS_MASTER = "#{SCRIPTS_PATH}/rails/master.sh"
  RAILS_RELEASE = "#{SCRIPTS_PATH}/rails/releases.sh"

  SEQUEL_MASTER = "#{SCRIPTS_PATH}/sequel/master.sh"
  SEQUEL_RELEASE = "#{SCRIPTS_PATH}/sequel/releases.sh"

  BUNDLER_RELEASE = "#{SCRIPTS_PATH}/bundler/releases.sh"

  # Use keyword arguments once Rails 4.2.1 has been released.
  def perform(initiator_key, benchmark_group, options = {})
    Net::SSH.start(
      bare_metal_server_ip,
      bare_metal_server_user,
      password: bare_metal_server_password
    ) do |ssh|

      send(benchmark_group, ssh, initiator_key, options)
    end
  end

  private

  def ruby_trunk(ssh, commit_hash, options)
    ruby = true
    memory = true
    optcarrot = true
    liquid = true
    patterns = options[:include_patterns]

    ssh_exec!(
      ssh,
      "#{RUBY_TRUNK} #{ruby} #{memory} #{optcarrot} #{liquid} #{commit_hash} #{api_name} #{api_password} #{patterns}"
    )
  end

  def ruby_releases(ssh, version, options)
    ruby = true
    memory = true
    optcarrot = true
    liquid = true
    patterns = options[:include_patterns]

    ssh_exec!(
      ssh,
      "#{RUBY_RELEASE} #{ruby} #{memory} #{optcarrot} #{liquid} #{version} #{api_name} #{api_password} #{patterns}"
    )
  end

  def ruby_releases_discourse(ssh, ruby_version, options)
    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/ruby_releases_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm
          --link discourse_postgres:postgres
          --link discourse_redis:redis
          -e \"RUBY_VERSION=#{ruby_version}\"
          -e \"API_NAME=#{api_name}\"
          -e \"API_PASSWORD=#{api_password}\"
          rubybench/ruby_releases_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm -v discourse_postgres discourse_redis"
      ]
    )
  end

  def ruby_trunk_discourse(ssh, commit_hash, options)
    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/ruby_trunk_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm --link discourse_postgres:postgres
          --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{api_name}\"
          -e \"API_PASSWORD=#{api_password}\"
          rubybench/ruby_trunk_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm -v discourse_postgres discourse_redis"
      ]
    )
  end

  def rails_releases(ssh, version, options)
    prepared_statements = if version >= '4.2.5' then 1 else 0 end
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{RAILS_RELEASE} #{version} #{api_name} #{api_password} #{prepared_statements} #{patterns}")
  end

  def rails_trunk(ssh, commit_hash, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{RAILS_MASTER} #{commit_hash} #{api_name} #{api_password} #{patterns}")
  end

  def sequel_releases(ssh, version, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{SEQUEL_RELEASE} #{version} #{api_name} #{api_password} #{patterns}")
  end

  def sequel_trunk(ssh, commit_hash, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{SEQUEL_MASTER} #{commit_hash} #{api_name} #{api_password} #{patterns}")
  end

  def bundler_releases(ssh, version, options)
    patterns = options[:include_patterns]

    ssh_exec!(ssh, "#{BUNDLER_RELEASE} #{version} #{api_name} #{api_password} #{patterns}")
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

  def bare_metal_server_ip
    Rails.application.secrets.bare_metal_server_ip
  end

  def bare_metal_server_user
    Rails.application.secrets.bare_metal_server_user
  end

  def bare_metal_server_password
    Rails.application.secrets.bare_metal_server_password
  end

  def api_name
    Rails.application.secrets.api_name
  end

  def api_password
    Rails.application.secrets.api_password
  end
end
