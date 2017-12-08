require 'rubygems'
require 'rest-client'
require 'json'
require 'csv'

module StockQuote

  # => SecQuote::Stock
  # Queries GoogleFinance for current and historical pricing.

  class Stock

   FIELDS = %w(symbol exchange id t e name f_reuters_url f_recent_quarter_date f_annlyal_date f_ttm_date financials kr_recent_quarter_date kr_annual_date kr_ttm_date c l cp ccol op hi lo vo avvo hi52 lo52 mc pe fwpe beta eps dy ldiv shares instown eo sid sname iid iname related summary management moreresources events)

   FIELDS.each do |k|
      __send__(:attr_accessor, k.to_sym)
    end

    attr_accessor :response_code, :history

    def initialize(data={})
      data.each {|k,v|
        self.instance_variable_set("@#{k}".to_sym, v)
      }
      @response_code = 200
    end

    def self.quote(symbol, startdate=nil, enddate=nil, format= nil)
      url = "https://finance.google.com/finance#{!!(startdate || enddate) ? '/historical' : ''}"
      params = {}
      results = []
      params.merge!(output:  !!(startdate || enddate) ? 'csv' : 'json')
      params.merge!(startdate: startdate) if !!(startdate)
      params.merge!(enddate: enddate) if !!(enddate)
      symbol.split(/,/).each do |s|
        params.merge!(q: s)
        u = "#{url}?#{URI.encode_www_form(params)}"
        RestClient::Request.execute(:url => u, :method => :get, :verify_ssl => false) do |response|
          if !!(startdate || enddate)
            fail "Invalid Query" if response.body.match(/^<!DOCTYPE html>/)
            csv = CSV.new(response.body[3..-1], :headers => true, :header_converters => :symbol, :converters => :all)
            json = {symbol: s, history: csv.to_a.map {|row| row.to_hash }}
            if format == 'json'
              results << json
            else
              results << Stock.new(json)
            end
          else
            json = response.body.gsub(/\n/, "")
            json = json.match(/\/\/ \[/) ? JSON.parse(json[3..-1])[0] : JSON.parse(json)["searchresults"]
            if json.is_a?(Array)
              json.each do |j|
                results << (format=='json' ? j : Stock.new(j))
              end
            else
              results << (format=='json' ? json : Stock.new(json))
            end
          end
        end
      end
      return results.length > 1 ? results : results.shift
    end

    def self.json_quote(symbol, format='json')
      self.quote(symbol, nil, nil, format)
    end

    def self.history(symbol, start_date=nil, end_date=nil, format='json')
      self.quote(symbol, start_date, end_date, format)
    end

    def self.json_history(symbol, start_date=nil, end_date=nil, format='json')
      self.quote(symbol, start_date, end_date, format)
    end
  end
end
