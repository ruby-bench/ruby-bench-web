require 'uri'
require 'net/http'
require 'json'

uri = URI.parse("https://api.travis-ci.org/repo/ruby-bench%2Fruby-bench-docker/requests")
http_client = Net::HTTP.new(uri.host, uri.port)
http_client.use_ssl = true
request = Net::HTTP::Post.new(uri.path)
token = `travis token --org`.gsub(/\n/, "")
request["Content-Type"] = 'application/json'
request["Accept"] = 'application/json'
request["Travis-API-Version"] = '3'
request["Authorization"] = 'token '+token
request.body = {'request' => {'branch' => 'master'}}.to_json
response = http_client.request(request)
