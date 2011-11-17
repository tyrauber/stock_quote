require "rest-client"
require "hpricot"

module StockQuote
  class Stock
      
      attr_accessor :symbol, :pretty_symbol, :symbol_lookup_url, :company, :exchange, :exchange_timezone, :exchange_utc_offset, :exchange_closing, :divisor, :currency, :last, :high, :low, :volume, :avg_volume, :market_cap, :open, :y_close, :change, :perc_change, :delay, :trade_timestamp, :trade_date_utc, :trade_time_utc, :current_date_utc, :current_time_utc, :symbol_url, :chart_url, :disclaimer_url, :ecn_url, :isld_last, :isld_trade_date_utc, :isld_trade_time_utc, :brut_last, :brut_trade_date_utc, :brut_trade_time_utc, :daylight_savings
      
    def initialize(symbol, pretty_symbol, symbol_lookup_url, company, exchange, exchange_timezone, exchange_utc_offset, exchange_closing, divisor, currency, last, high, low, volume, avg_volume, market_cap, open, y_close, change, perc_change, delay, trade_timestamp, trade_date_utc, trade_time_utc, current_date_utc, current_time_utc, symbol_url, chart_url, disclaimer_url, ecn_url, isld_last, isld_trade_date_utc, isld_trade_time_utc, brut_last, brut_trade_date_utc, brut_trade_time_utc, daylight_savings)  
          # Instance variables  
            @symbol = symbol
            @pretty_symbol = pretty_symbol
            @symbol_lookup_url = symbol_lookup_url
            @company = company
            @exchange = exchange
            @exchange_timezone = exchange_timezone 
            @exchange_utc_offset = exchange_utc_offset
            @exchange_closing = exchange_closing
            @divisor = divisor
            @currency = currency
            @last = last
            @high = high 
            @low = low
            @volume = volume
            @avg_volume = avg_volume
            @market_cap = market_cap
            @open = open
            @y_close = y_close
            @change = change
            @perc_change = perc_change
            @delay = delay
            @trade_timestamp = trade_timestamp 
            @trade_date_utc = trade_date_utc
            @trade_time_utc = trade_time_utc
            @current_date_utc = current_date_utc
            @current_time_utc = current_time_utc
            @symbol_url = symbol_url
            @chart_url = chart_url
            @disclaimer_url = disclaimer_url
            @ecn_url = ecn_url
            @isld_last = isld_last
            @isld_trade_date_utc = isld_trade_date_utc
            @isld_trade_time_utc = isld_trade_time_utc
            @brut_last = brut_last
            @brut_trade_date_utc = brut_trade_date_utc 
            @brut_trade_time_utc = brut_trade_time_utc
            @daylight_savings = daylight_savings
        
    end  
      
    def self.find(symbol)
        url = "http://www.google.com/ig/api?"
        query =[]
        symbols = symbol.gsub(" ", "").split(",")
        for s in symbols
            query << "stock="+s
        end
        RestClient.get(url+query.join("&")){ |response, request, result, &block|
            case response.code
                when 200
                    self.parse(response)
                else
                    response.return!(request, result, &block)
                end
            }
    end
    def self.parse(xml)
        doc = Hpricot::XML(xml)
        data = doc.search(:finance);
        results = []
        for d in data
            stock=Stock.new(d.search(:symbol).first.attributes['data'],
                            d.search(:pretty_symbol).first.attributes['data'],
                            d.search(:symbol_lookup_url).first.attributes['data'],
                            d.search(:company).first.attributes['data'],
                            d.search(:exchange).first.attributes['data'],
                            d.search(:exchange_timezone).first.attributes['data'],
                            d.search(:exchange_utc_offset).first.attributes['data'],
                            d.search(:exchange_closing).first.attributes['data'],
                            d.search(:divisor).first.attributes['data'],
                            d.search(:currency).first.attributes['data'],
                            d.search(:last).first.attributes['data'],
                            d.search(:high).first.attributes['data'],
                            d.search(:low).first.attributes['data'],
                            d.search(:volume).first.attributes['data'],
                            d.search(:avg_volume).first.attributes['data'],
                            d.search(:market_cap).first.attributes['data'],
                            d.search(:open).first.attributes['data'],
                            d.search(:y_close).first.attributes['data'],
                            d.search(:change).first.attributes['data'],
                            d.search(:perc_change).first.attributes['data'],
                            d.search(:delay).first.attributes['data'],
                            d.search(:trade_timestamp).first.attributes['data'],
                            d.search(:trade_date_utc).first.attributes['data'],
                            d.search(:trade_time_utc).first.attributes['data'],
                            d.search(:current_date_utc).first.attributes['data'],
                            d.search(:current_time_utc).first.attributes['data'],
                            d.search(:symbol_url).first.attributes['data'],
                            d.search(:chart_url).first.attributes['data'],
                            d.search(:disclaimer_url).first.attributes['data'],
                            d.search(:ecn_url).first.attributes['data'],
                            d.search(:isld_last).first.attributes['data'],
                            d.search(:isld_trade_date_utc).first.attributes['data'],
                            d.search(:isld_trade_time_utc).first.attributes['data'],
                            d.search(:brut_last).first.attributes['data'],
                            d.search(:brut_trade_date_utc).first.attributes['data'],
                            d.search(:brut_trade_time_utc).first.attributes['data'],
                            d.search(:daylight_savings).first.attributes['data']
                      )
            if data.count ==1
                results = stock; 
            else
                results << stock;
            end
        end
        return results;
    end
  end
end

