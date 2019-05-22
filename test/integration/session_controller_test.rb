require 'test_helper'

def sso_response(url)
  parsed = Rack::Utils.parse_query(url.split("?")[-1])
  decoded = Base64.decode64(parsed["sso"])
  decoded_hash = Rack::Utils.parse_query(decoded)
  return_sso_url = URI.parse(decoded_hash["return_sso_url"]).path

  user_data = {
    username: "somebody",
    email: "validemail@rubybench.org",
    external_id: "9746",
    nonce: decoded_hash["nonce"]
  }

  query = Rack::Utils.build_query(user_data)
  payload = Base64.strict_encode64(query)
  escaped = CGI::escape(payload)
  signed = OpenSSL::HMAC.hexdigest("sha256", Rails.application.secrets.sso_secret, payload)

  ["#{return_sso_url}?sso=#{escaped}&sig=#{signed}", decoded_hash["nonce"]]
end

class SessionControllerTest < ActionDispatch::IntegrationTest
  test 'should allow users to login' do
    get "/login"
    assert_equal(302, response.status)

    location = response.headers["Location"]
    assert_includes(location, AppSettings.forum_url)


    get sso_response(location)[0]
    assert_equal(302, response.status)
    current_user = controller.current_user
    assert_equal("somebody", current_user.username)
    assert_equal("9746", current_user.external_id)
  end

  test 'shouldn\'t allow users to login if nonce is gone from redis' do
    get "/login"
    assert_equal(302, response.status)
    location = response.headers["Location"]
    url, nonce = sso_response(location)
    $redis.stubs(:get).with(nonce).returns(nil)

    get url
    assert_equal(422, response.status)
    assert_nil(controller.current_user)
  end
end
