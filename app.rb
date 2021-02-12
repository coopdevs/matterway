require 'sinatra'
require 'net/http'
require 'httplog'

TARGET_URL = URI(ENV['TARGET_URL'])
PIPELINE_URL = 'https://dashboard.heroku.com/pipelines/fe96351a-96ed-4b26-8076-57930ac6d33a'

post '/' do
  body = request.body.read
  return status 400 if body == ''

  webhook = JSON.parse(body)
  mattermost_body = { text: message_from(webhook) }.to_json

  response = Net::HTTP.start(TARGET_URL.host, TARGET_URL.port, use_ssl: true) do |http|
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = mattermost_body
    http.request(req)
  end

  response
end

def message_from(body)
  data = body['data']
  user = data['user']
  slug = data['slug']
  app = data['app']

  "#{user['email']} deployed `#{slug['commit']}` to [#{app['name']}](#{PIPELINE_URL})"
end
