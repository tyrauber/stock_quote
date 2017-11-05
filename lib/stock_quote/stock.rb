require 'rubygems'
require 'rest-client'
require 'json'
require 'csv'

module StockQuote

  # => SecQuote::Stock
  # Queries GoogleFinance for current and historical pricing.

  class Stock

   FIELDS = {
      id: 'id',
      t: 'symbol',
      e: 'index',
      l: 'last_trade_price',
      l_cur: 'last_trade_with_currency',
      ltt: 'last_trade_time',
      lt_dts: 'last_trade_date_time',
      lt: 'last_trade_date_time_long',
      div: 'dividend',
      yld: 'yield',
      s: 'last_trade_size',
      c: 'change',
      cp: 'change_percent',
      el: 'ext_hrs_last_trade_price',
      el_cur: 'ext_hrs_last_trade_with_currency',
      elt: 'ext_hrs_last_trade_date_time_long',
      ec: 'ext_hrs_change',
      ecp: 'ext_hrs_change_percent',
      pcls_fix: 'previous_close_price'
    }
    
    
    FIELDS.each do |k,v|
      __send__(:attr_accessor, v.to_sym)
      __send__(:alias_method, k, v.to_sym)
    end

    attr_accessor :response_code, :history

    def initialize(data={})
      data.each {|k,v| self.instance_variable_set("@#{k}".to_sym, v)}
      @response_code = 200
    end

    def self.quote(symbol, startdate=nil, enddate=nil, format= nil)
      url = "https://finance.google.com/finance#{historical ? '/historical' : ''}"
      params = {}
      results = []
      params.merge!(output:  !!(startdate || enddate) ? 'csv' : 'json')
      params.merge!(startdate: startdate) if !!(startdate)
      params.merge!(enddate: enddate) if !!(enddate)
      symbol.split(/\W/).each do |s|
        params.merge!(q: s)
        u = "#{url}?#{URI.encode_www_form(params)}"
        RestClient::Request.execute(:url => u, :method => :get, :verify_ssl => false) do |response|
          if !!(startdate || enddate)
            csv = CSV.new(response.body[3..-1], :headers => true, :header_converters => :symbol, :converters => :all)
            json = {symbol: s, history: csv.to_a.map {|row| row.to_hash }}
            if format == 'json'
              results << json
            else
              results << Stock.new(json)
            end
          else
            json = JSON.parse(response.body.gsub(/\n/, "")[3..-1])[0]
            if format == 'json'
              results << json
            else
              results << Stock.new(json)
            end
          end
        end
      end
      return results.length > 1 ? results : results.shift
    end
    
    def self.json_quote(symbol, start_date=nil, end_date=nil, format=nil)
      self.quote(symbol, start_date, end_date, 'json')
    end
    
    def self.history(symbol, start_date=nil, end_date=nil, format=nil)
      self.history(symbol, start_date, end_date, format)
    end
    
    def self.json_history(symbol, start_date=nil, end_date=nil, format=nil)
      self.history(symbol, start_date, end_date, 'json')
    end
  end
end
