require 'sinatra'

uri = URI('https://coopdevs.cloud.mattermost.com/hooks/ywzoftw9nj8ougbueyy4ds4t6y')

post '/' do
  webhook = JSON.parse(request.body.read)
  body = { text: message_from(webhook) }.to_json

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = body
    http.request(req)
  end

  response
end

def message_from(body)
  data = body['data']
  app = data['app']

  "#{user['email']} deployed `#{slug['commit']}` to #{app['name']}" 
end
