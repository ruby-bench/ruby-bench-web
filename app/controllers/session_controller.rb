class SessionController < ApplicationController
  def sso
    sso = DiscourseApi::SingleSignOn.parse(request.query_string, Rails.application.secrets.sso_secret)
    return_url = $redis.get(sso.nonce)
    if return_url.present?
      session[:user] = {
        username: sso.username,
        email: sso.email,
        external_id: sso.external_id
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
    $redis.setex(sso.nonce, 10.minutes.to_i, '/')
    redirect_to sso.to_url
  end
end
