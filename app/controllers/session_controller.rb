class SessionController < ApplicationController
  USERNAMES = %w{john osama sam tgx patrick}
  TRUSTED_GROUP_NAME = 'trusted-users'

  def sso
    sso = DiscourseApi::SingleSignOn.parse(request.query_string, Rails.application.secrets.sso_secret)
    return_url = $redis.get(sso.nonce)
    if return_url.present?
      session[:user] = {
        username: sso.username,
        external_id: sso.external_id,
        trusted: is_trusted?(sso)
      }
      redirect_to return_url
    else
      render plain: "Couldn't authenticate via SSO.", status: 422
    end
  end

  def login
    sso = DiscourseApi::SingleSignOn.new
    sso.sso_secret = Rails.application.secrets.sso_secret
    sso.return_sso_url = "#{request.base_url}/sso"
    sso.nonce = SecureRandom.hex
    sso.sso_url = "#{AppSettings.forum_url}/session/sso_provider"
    path = session[:destination_url] || '/'
    $redis.setex(sso.nonce, 10.minutes.to_i, path)
    redirect_to sso.to_url
  end

  def become
    if Rails.env.production?
      render plain: "Can't use this endpoint in production", status: 403
      return
    end

    permitted = params.permit([:username, :external_id, :trusted])
    hash = {
      username: "#{USERNAMES.sample}#{SecureRandom.random_number(20)}",
      external_id: SecureRandom.random_number(1000),
      trusted: false
    }.merge(permitted.to_h.symbolize_keys.slice(:username, :external_id, :trusted))

    hash[:trusted] = [true, 'true'].include?(hash[:trusted])
    session[:user] = hash
    redirect_to '/'
  end

  private

  def is_trusted?(sso)
    sso.admin || sso&.groups&.first&.split(',')&.include?(TRUSTED_GROUP_NAME)
  end
end
