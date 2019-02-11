# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'stock_quote/version'

Gem::Specification.new do |s|
  s.name        = 'stock_quote'
  s.version     = StockQuote::VERSION
  s.authors     = ['Ty Rauber']
  s.email       = ['tyrauber@mac.com']
  s.homepage    = 'https://github.com/tyrauber/stock_quote'
  s.summary     = 'A ruby gem that retrieves real-time stock quotes from IEX.'
  s.description = 'Retrieve book, chart, company, delayed quote, dividends, earnings, effective spread, financials, stats, lists, logo, news, OHLC, open/close, peers, previous, price, quote, relevant, splits, timeseries, volume by venue and batch requests through IEX (iextrading.com/developer)'
  s.rubyforge_project = 'stock_quote'
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:

  s.add_development_dependency 'bundler', '~> 2.0.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
  s.add_development_dependency 'vcr', '~> 4.0.0'
  s.add_development_dependency 'webmock', '~> 3.4.2'
  s.add_runtime_dependency 'rest-client', '~> 2.0.2'
  s.add_runtime_dependency 'json'

end
