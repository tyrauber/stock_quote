require "rubygems"
require "rest-client"
require "hpricot"
require "date"

module StockQuote

  class Price
    attr_accessor :date, :open, :high, :low, :close, :volume

    def initialize(date,open,high,low,close, volume)
      date = date.split("-")
      @date = Time.utc(date[2],date[1],date[0].to_i)
      @open = open.to_f
      @high = high.to_f
      @low = low.to_f
      @close = close.to_f
      @volume = volume.to_i
    end
  end
    
  class Stock

    @@fields = ['symbol', 'pretty_symbol', 'symbol_lookup_url', 'company', 'exchange', 'exchange_timezone', 'exchange_utc_offset', 'exchange_closing', 'divisor', 'currency', 'last', 'high', 'low', 'volume', 'avg_volume', 'market_cap', 'open', 'y_close', 'change', 'perc_change', 'delay', 'trade_timestamp', 'trade_date_utc', 'trade_time_utc', 'current_date_utc', 'current_time_utc', 'symbol_url', 'chart_url', 'disclaimer_url', 'ecn_url', 'isld_last', 'isld_trade_date_utc', 'isld_trade_time_utc', 'brut_last', 'brut_trade_date_utc', 'brut_trade_time_utc', 'daylight_savings']
    attr_accessor :response_code, :no_data_message

    @@fields.each do | field|
      self.__send__(:attr_accessor, field.to_sym)
    end

    def initialize(data)
      @response_code = 200
      @@fields.each do |field|
        atts = data.search(field.to_sym)
        if !atts.empty?
          value = atts.first.attributes['data']
          value = value.to_f == 0.0 ? value : value.to_f
          instance_variable_set("@#{field}", value)
        else
          @no_data_message = data.search(:no_data_message).first.attributes['data']
          @response_code = 404
        end
      end
    end

    def success?
      response_code==200
    end

    def failure?
      response_code==404
    end

    def self.quote(symbol)
      url = "http://www.google.com/ig/api?"
      query = symbol.gsub(" ", "").split(",").map{|s| "stock="+s}
      response = RestClient.get(url+query.join("&"))
      self.parse(response)
    end

    def self.parse(xml)
      doc = Hpricot::XML(xml)
      data = doc.search(:finance)
      results = []
      for d in data
        stock = Stock.new(d)
        return stock if data.count ==1
        results << stock
      end
      return results
    end

    def self.history(symbol)
      url =  "http://www.google.com/finance/historical?q="+symbol+"&output=csv"
      response = RestClient.get(url) rescue []
      return response if response.empty?
      self.parse_history(response)
    end

    def self.parse_history(response)
      timeline = response.split("\n")
      results = []
      for row in timeline
        if row[-6,6] != "Volume"
          row = row.split(",")
          p=Price.new(row[0],row[1],row[2], row[3], row[4], row[5])
          results << p
        end
      end
      return results
    end
  end
end

