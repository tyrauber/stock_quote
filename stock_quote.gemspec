# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'stock_quote/version'

Gem::Specification.new do |s|
  s.name        = 'stock_quote'
  s.version     = StockQuote::VERSION
  s.authors     = ['Ty Rauber']
  s.email       = ['tyrauber@mac.com']
  s.homepage    = 'https://github.com/tyrauber/stock_quote'
  s.summary     = 'A ruby gem that retrieves real-time stock quotes from google.'
  s.description = 'Retrieve up to 100 stock quotes per query with the following variables - symbol, pretty_symbol, symbol_lookup_url, company, exchange, exchange_timezone, exchange_utc_offset, exchange_closing, divisor, currency, last, high, low, volume, avg_volume, market_cap, open, y_close, change, perc_change, delay, trade_timestamp, trade_date_utc, trade_time_utc, current_date_utc, current_time_utc, symbol_url, chart_url, disclaimer_url, ecn_url, isld_last, isld_trade_date_utc, isld_trade_time_utc, brut_last, brut_trade_date_utc, brut_trade_time_utc and daylight_savings - per stock.'
  s.rubyforge_project = 'stock_quote'
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:

  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'vcr', '~> 2.9'
  s.add_development_dependency 'webmock', '~> 1.17'
  s.add_development_dependency 'rubocop', '~> 0.20'
  s.add_runtime_dependency 'rest-client', '~> 1.6'
  s.add_runtime_dependency 'json'

end
