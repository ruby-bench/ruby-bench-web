require 'net/ssh'

class RemoteServerJob < ActiveJob::Base
  queue_as :default

  # Use keyword arguments once Rails 4.2.1 has been released.
  def perform(initiator_key, benchmark, options = {})
    secrets = Rails.application.secrets

    Net::SSH.start(
      secrets.bare_metal_server_ip,
      secrets.bare_metal_server_user,
      password: secrets.bare_metal_server_password
    ) do |ssh|

      send(benchmark, ssh, initiator_key, options)
    end
  end

  private

  def ruby_trunk(ssh, commit_hash, options)
    options.reverse_merge!({ ruby_benchmarks: true, ruby_memory_benchmarks: true })

    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/ruby_trunk",
        "docker run --rm
          -e \"RUBY_BENCHMARKS=#{options[:ruby_benchmarks]}\"
          -e \"RUBY_MEMORY_BENCHMARKS=#{options[:ruby_memory_benchmarks]}\"
          -e \"RUBY_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          #{build_include_patterns(options[:include_patterns])}
          rubybench/ruby_trunk".squish
      ]
    )
  end

  def ruby_releases(ssh, ruby_version, options)
    options.reverse_merge!({ ruby_benchmarks: true, ruby_memory_benchmarks: true })

    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/ruby_releases",
        "docker run --rm
          -e \"RUBY_BENCHMARKS=#{options[:ruby_benchmarks]}\"
          -e \"RUBY_MEMORY_BENCHMARKS=#{options[:ruby_memory_benchmarks]}\"
          -e \"RUBY_VERSION=#{ruby_version}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          #{build_include_patterns(options[:include_patterns])}
          rubybench/ruby_releases".squish
      ]
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
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
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
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          rubybench/ruby_trunk_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm -v discourse_postgres discourse_redis"
      ]
    )
  end

  def rails_releases(ssh, rails_version, options)
    custom_env = ''
    custom_env = '-e "MYSQL2_PREPARED_STATEMENTS=1"' if rails_version >= '4.2.5'

    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/rails_releases",
        "docker run --name postgres -d postgres:9.3.5",
        "docker run --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -d mysql:5.6.24",
        "docker run --name redis -d redis:2.8.19",
        "docker run --rm
          --link postgres:postgres
          --link mysql:mysql
          --link redis:redis
          -e \"RAILS_VERSION=#{rails_version}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          #{custom_env}
          #{build_include_patterns(options[:include_patterns])}
          rubybench/rails_releases".squish,
        "docker stop postgres mysql redis",
        "docker rm -v postgres mysql redis"
      ]
    )
  end

  def rails_trunk(ssh, commit_hash, options)
    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/rails_trunk",
        "docker run --name postgres -d postgres:9.3.5",
        "docker run --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -d mysql:5.6.24",
        "docker run --name redis -d redis:2.8.19",
        "docker run --rm
          --link postgres:postgres
          --link mysql:mysql
          --link redis:redis
          -e \"RAILS_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          -e \"MYSQL2_PREPARED_STATEMENTS=1\"
          #{build_include_patterns(options[:include_patterns])}
          rubybench/rails_trunk".squish,
        "docker stop postgres mysql redis",
        "docker rm -v postgres mysql redis"
      ]
    )
  end

  def bundler_releases(ssh, bundler_version, options)
    execute_ssh_commands(ssh,
      [
        "docker pull rubybench/bundler_releases",
        "docker run --rm
          -e \"BUNDLER_VERSION=#{bundler_version}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          #{build_include_patterns(options[:include_patterns])}
          rubybench/bundler_releases".squish
      ]
    )
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
end
