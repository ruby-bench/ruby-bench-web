class RemoteServerJob < ApplicationJob
  queue_as :default

  def perform(initiator_key, benchmark, *kwargs)
    secrets = Rails.application.secrets

    Net::SSH.start(
      secrets.bare_metal_server_ip,
      secrets.bare_metal_server_user,
      password: secrets.bare_metal_server_password
    ) do |ssh|

      send(benchmark, ssh, initiator_key, *kwargs)
    end
  end

  private

  def ruby_bench(ssh, commit_hash, ruby_benchmarks: true, ruby_memory_benchmarks: true)
    execute_ssh_commands(ssh,
      [
        "docker pull tgxworld/ruby_bench",
        "docker run --rm
          -e \"RUBY_BENCHMARKS=#{ruby_benchmarks}\"
          -e \"RUBY_MEMORY_BENCHMARKS=#{ruby_memory_benchmarks}\"
          -e \"RUBY_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          tgxworld/ruby_bench".squish
      ]
    )
  end

  def ruby_releases(ssh, ruby_version, ruby_benchmarks: true, ruby_memory_benchmarks: true)
    execute_ssh_commands(ssh,
      [
        "docker pull tgxworld/ruby_releases",
        "docker run --rm
          -e \"RUBY_BENCHMARKS=#{ruby_benchmarks}\"
          -e \"RUBY_MEMORY_BENCHMARKS=#{ruby_memory_benchmarks}\"
          -e \"RUBY_VERSION=#{ruby_version}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          tgxworld/ruby_releases".squish
      ]
    )
  end

  def ruby_releases_discourse(ssh, ruby_version)
    execute_ssh_commands(ssh,
      [
        "docker pull tgxworld/ruby_releases_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm
          --link discourse_postgres:postgres
          --link discourse_redis:redis
          -e \"RUBY_VERSION=#{ruby_version}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          tgxworld/ruby_releases_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm discourse_postgres discourse_redis"
      ]
    )
  end

  def discourse_rails_head_bench(ssh, commit_hash)
    execute_ssh_commands(ssh,
      [
        "docker pull tgxworld/discourse_rails_head_bench",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm --link discourse_postgres:postgres
          --link discourse_redis:redis -e \"RAILS_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          tgxworld/discourse_rails_head_bench".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm discourse_postgres discourse_redis"
      ]
    )
  end

  def ruby_bench_discourse(ssh, commit_hash)
    execute_ssh_commands(ssh,
      [
        "docker pull tgxworld/ruby_bench_discourse",
        "docker run --name discourse_redis -d redis:2.8.19",
        "docker run --name discourse_postgres -d postgres:9.3.5",
        "docker run --rm --link discourse_postgres:postgres
          --link discourse_redis:redis -e \"RUBY_COMMIT_HASH=#{commit_hash}\"
          -e \"API_NAME=#{Rails.application.secrets.api_name}\"
          -e \"API_PASSWORD=#{Rails.application.secrets.api_password}\"
          tgxworld/ruby_bench_discourse".squish,
        "docker stop discourse_postgres discourse_redis",
        "docker rm discourse_postgres discourse_redis"
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
end
