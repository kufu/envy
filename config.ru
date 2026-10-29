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
