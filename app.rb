require 'bundler'
Bundler.require

require 'json'
require 'securerandom'
require 'logger'

$logger = Logger.new(STDOUT)

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    haml :index
  end

  post '/' do
    @inquiry_token = SecureRandom.hex(2).upcase # gain 4-digits hex token

    content = {}
    content[:inquery_token] = @inquiry_token
    content[:javascript_env] = JSON.parse(params[:jsenv])
    content[:http_headers] = request.env.select{ |header, _| header.start_with?('HTTP_') }

    payload = {
      token: ENV['SLACK_TOKEN'],
      channels: ENV['SLACK_CHANNEL'],
      filetype: 'javascript',
      initial_comment: params[:message],
      content: JSON.pretty_generate(content)
    }

    response = RestClient.post('https://slack.com/api/files.upload', payload)
    $logger.info(response.body)

    haml :thanks
  end
end
