require 'rack'

CONTENT_SECURITY_POLICY = [
  "default-src 'none'",
  "script-src 'self' https://system-requirements.smarthr.jp",
  "style-src 'self' https://maxcdn.bootstrapcdn.com",
  "font-src https://maxcdn.bootstrapcdn.com",
  "base-uri 'none'",
  "form-action 'none'",
  "frame-ancestors 'none'"
].join('; ')

# Heroku は HTTP のリクエストもそのまま受け付けるので、HTTPS にリダイレクトする
class ForceHttps
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.get_header('HTTP_X_FORWARDED_PROTO') == 'http'
      location = "https://#{request.host}#{request.fullpath}"
      return [301, { 'location' => location, 'content-type' => 'text/plain' }, ['Moved Permanently']]
    end

    status, headers, body = @app.call(env)
    headers['strict-transport-security'] = 'max-age=31536000' if request.get_header('HTTP_X_FORWARDED_PROTO') == 'https'
    [status, headers, body]
  end
end

use ForceHttps

use Rack::Static,
  urls: [''],
  root: 'public',
  index: 'index.html',
  header_rules: [
    [:all, {
      'content-security-policy' => CONTENT_SECURITY_POLICY,
      'referrer-policy' => 'no-referrer',
      'x-content-type-options' => 'nosniff',
      'x-frame-options' => 'DENY'
    }]
  ]

run ->(_env) { [404, { 'content-type' => 'text/plain' }, ['Not Found']] }
