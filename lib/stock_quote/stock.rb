require 'rubygems'
require 'rest-client'
require 'json'
require 'csv'

module StockQuote

  # => StockQuote::Stock
  # Queries IEX for current and historical pricing.

  class Stock

    VERSION = "v1"
    URL =  "https://cloud.iexapis.com/#{VERSION}/stock/"
    ATTRIBUTION = "Data provided for free by IEX (https://iexcloud.io)."
    RANGES = ['5y','2y','1y','ytd','6m','3m','1m','1d']
    TYPES = ['book', 'chart', 'company', 'delayed_quote', 'dividends', 'earnings', 'financials', 'splits', 'stats','logo', 'news', 'ohlc', 'peers', 'previous', 'quote', 'relevant', 'volume_by_venue']
  
    class << self
      attr_accessor :api_key
      def create_method(name)
        self.class.instance_eval do
          define_method(name) {|symbol, range=nil| batch(name, symbol, range) }
          define_method("raw_#{name}") {|symbol, range=nil| batch(name, symbol, range, 'json') }
        end
      end
    end

    attr_accessor :response_code, :attribution

    protected

    TYPES.each do |k|
      create_method(k)
    end

    def initialize(data={})
      self.class.api_key = data.delete(:api_key) if !!(data[:api_key])
      data.each {|k,v|
        self.class.__send__(:attr_accessor, Util.underscore(k).to_sym)
        self.instance_variable_set("@#{Util.underscore(k)}".to_sym, v)
      }
      @attribution = ATTRIBUTION
      @response_code = !!([{}, nil, ''].include?(data)) ? 500 :  200
    end

    def self.batch_url(types, symbols, range)
      symbols = symbols.is_a?(Array) ? symbols : symbols.split(",")
      types = types.is_a?(Array) ? types : types.split(",")
      if !(['dividends', 'splits'] & types).empty?
        raise "#{types.join(",")} requires a Range: #{RANGES.join(", ")}" unless RANGES.include?(range)
        range = RANGES.include?(range) ? range : nil
      end
      arr = [['token', self.api_key],['symbols', symbols.join(',')], ['types', types.map{|t| t.gsub("_", "-")}.join(',')]]
      arr.push(['range', range]) if !!(range)
      return "#{URL}market/batch?#{URI.encode_www_form(arr)}"
    end

    def self.batch(type, symbol, range=nil,fmt=false)
      raise "Type and symbol required" unless type && symbol
      url =  batch_url(type, symbol, range)
      return request(url, fmt)
    end
    
    def self.request(url, fmt, results=[])
      RestClient::Request.execute(:url =>  url, :method => :get, :verify_ssl => false) do |response|
        raise response.body unless response.code == 200
        json = JSON.parse(response)
        return json if fmt=='json'
        results = json.map do |symbol, types|
          result = {}
          types.map do |type, res|
            if res.is_a?(Array)
              result[type.gsub("-", "_")] = res
            else
              res.map{|k,v| result[k] = v }
            end
            result['symbol'] ||= symbol
          end
          Stock.new(result)
        end
      end
      return results.length > 1 ? results : results.shift
    end
  end

  class Util
    def self.underscore(str)
      str.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end
