class RemoteServerJob < ApplicationJob
  queue_as :default

  def perform(commit_hash, repo_name)
    secrets = Rails.application.secrets

    Net::SSH.start(
      secrets.bare_metal_server_ip,
      secrets.bare_metal_server_user,
      password: secrets.bare_metal_server_password
    ) do |ssh|

      ssh.exec!(send("#{repo_name}_command", commit_hash)) do |channel, stream, data|
        puts data
      end
    end
  end

  private

  def rails_command(commit_hash)
    "sudo docker pull tgxworld/rails_bench && sudo docker run --rm -e
      \"RAILS_COMMIT_HASH=#{commit_hash}\" -e \"RUBY_VERSION=2.1.5\" -e
      \"KO1TEST_SEED_CNT=100\" tgxworld/rails_bench".squish
  end

  def ruby_command(commit_hash)
    "sudo docker pull tgxworld/ruby_bench && sudo docker run --rm -e
      \"RUBY_COMMIT_HASH=#{commit_hash}\" tgxworld/ruby_bench".squish
  end
end
