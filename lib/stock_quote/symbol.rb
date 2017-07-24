require 'rest-client'
require 'json'
require 'stock_quote/utility'
include StockQuote::Utility

module StockQuote
  class NoDataForCompanyError < StandardError; end
  class ApiChange < StandardError; end

  class Symbol
    FIELDS = %w[symbol name exch type exchDisp typeDisp].freeze

    FIELDS.each do |field|
      __send__(:attr_accessor, to_underscore(field).to_sym)
      __send__(:alias_method, field.to_sym, to_underscore(field).to_sym)
    end

    def self.fields
      FIELDS
    end

    def initialize(data)
      data.map do |k, v|
        instance_variable_set("@#{to_underscore(k)}", (v.nil? ? nil : to_format(v)))
      end
    end

    def self.lookup(company, exchanges = [])
      return [] if !company || company.strip.empty?
      url = "http://autoc.finance.yahoo.com/autoc?query=#{company}&region=US&lang=en-GB"
      RestClient::Request.execute(url: url, method: :get, verify_ssl: false) do |response|
        if response.code == 200
          parse(response, exchanges)
        else
          raise(NoDataForCompanyError, "Problem with company lookup. response: #{response.inspect}")
        end
      end
    end

    def self.parse(json, exchanges = [])
      results = []
      json = JSON.parse(json).fetch('ResultSet')
      return [] unless json['Result']
      json['Result'].each do |symbol_data|
        results << Symbol.new(symbol_data)
      end
      exchanges.empty? ? results : results.select { |symbol| exchanges.include?(symbol.exch) }
    end
  end
end
