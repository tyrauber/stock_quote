require 'stock_quote'
require 'rubygems'
require 'bundler/setup'
require 'vcr_setup'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end