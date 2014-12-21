class RemoteServerJob < ApplicationJob
  queue_as :default

  def perform(commit_hash, benchmark)
    secrets = Rails.application.secrets

    Net::SSH.start(
      secrets.bare_metal_server_ip,
      secrets.bare_metal_server_user,
      password: secrets.bare_metal_server_password
    ) do |ssh|

      send(benchmark, ssh, commit_hash)
    end
  end

  private

  def ruby_bench(ssh, commit_hash)
    [
      "docker pull tgxworld/ruby_bench",
      "docker run --rm -e \"RUBY_COMMIT_HASH=#{commit_hash}\" tgxworld/ruby_bench"
    ].each do |command|

      ssh_exec!(ssh, command)
    end
  end

  def ssh_exec!(ssh, command)
    ssh.exec!(command) do |channel, stream, data|
      puts data if stream == :stdout
    end
  end
end
