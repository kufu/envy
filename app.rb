require 'bundler'
Bundler.require

require 'json'
require 'securerandom'
require 'logger'
require 'slack-ruby-client'

$logger = Logger.new(STDOUT)

Slack.configure do |config|
    config.token = ENV['BOT_USER_OAUTH_TOKEN']
end

def send_slack_message(initial_comment, msg)
    channel_id = 'C66CZ53PE' # #envy

    client = Slack::Web::Client.new
    response = client.chat_postMessage(
        channel: channel_id,
        text: initial_comment,
        # blocks: %Q|[{"type":"section","text":{"type":"mrkdwn","text": "#{msg}"}}]|
        blocks: JSON.dump([{type: 'section', text: {type: 'mrkdwn', text: msg}}])
    )
end

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

    # payload = {
    #   token: ENV['SLACK_TOKEN'],
    #   channels: ENV['SLACK_CHANNEL'],
    #   filetype: 'javascript',
    #   initial_comment: params[:message],
    #   content: JSON.pretty_generate(content)
    # }

    begin
      send_slack_message(params[:message], JSON.pretty_generate(content))
    rescue StandardError => e
      $logger.error "Error sending message to Slack: #{e.message}"
    end

    haml :thanks
  end
end
