require 'rubygems'
require 'rest-client'
require 'json'
require 'date'
include StockQuote::Utility

module StockQuote
  # => SecQuote::NoDataForStockError
  # Is returned for 404s and ErrorIndicationreturnedforsymbolchangedinvalid
  class NoDataForStockError < StandardError
    attr_reader :no_data_message
    def initialize(data = {}, *)
      if data['ErrorIndicationreturnedforsymbolchangedinvalid']
        @no_data_message = data['ErrorIndicationreturnedforsymbolchangedinvalid']
      elsif data['diagnostics'] && data['diagnostics']['warning']
        @no_data_message = data['diagnostics']['warning']
      elsif data['count'] && data['count'] == 0
        @no_data_message = 'Query returns no valid data'
      end
    end
    def failure?; true end
    def success?; false end
    def response_code; 404 end
  end

  # => SecQuote::Stock
  # Queries Yahoo for current and historical pricing.
  class Stock
    FIELDS = %w(Symbol Ask AverageDailyVolume Bid AskRealtime BidRealtime BookValue Change_PercentChange Change Commission ChangeRealtime AfterHoursChangeRealtime DividendShare LastTradeDate TradeDate EarningsShare ErrorIndicationreturnedforsymbolchangedinvalid EPSEstimateCurrentYear EPSEstimateNextYear EPSEstimateNextQuarter DaysLow DaysHigh YearLow YearHigh HoldingsGainPercent AnnualizedGain HoldingsGain HoldingsGainPercentRealtime HoldingsGainRealtime MoreInfo OrderBookRealtime MarketCapitalization MarketCapRealtime EBITDA ChangeFromYearLow PercentChangeFromYearLow LastTradeRealtimeWithTime ChangePercentRealtime ChangeFromYearHigh PercentChangeFromYearHigh LastTradeWithTime LastTradePriceOnly HighLimit LowLimit DaysRange DaysRangeRealtime FiftydayMovingAverage TwoHundreddayMovingAverage ChangeFromTwoHundreddayMovingAverage PercentChangeFromTwoHundreddayMovingAverage ChangeFromFiftydayMovingAverage PercentChangeFromFiftydayMovingAverage Name Notes Open PreviousClose PricePaid ChangeinPercent PriceSales PriceBook ExDividendDate PERatio DividendPayDate PERatioRealtime PEGRatio PriceEPSEstimateCurrentYear PriceEPSEstimateNextYear Symbol SharesOwned ShortRatio LastTradeTime TickerTrend OneyrTargetPrice Volume HoldingsValue HoldingsValueRealtime YearRange DaysValueChange DaysValueChangeRealtime StockExchange DividendYield PercentChange ErrorIndicationreturnedforsymbolchangedinvalid Date Open High Low Close AdjClose)

    attr_accessor :response_code, :no_data_message

    FIELDS.each do |field|
      __send__(:attr_accessor, to_underscore(field).to_sym)
      __send__(:alias_method, field.to_sym, to_underscore(field).to_sym)
    end

    # Fix spelling yahoo error
    __send__(:attr_accessor, to_underscore('PercebtChangeFromYearHigh').to_sym)
    __send__(:alias_method, 'PercentChangeFromYearHigh'.to_sym, to_underscore('PercebtChangeFromYearHigh').to_sym)
    __send__(:alias_method,  to_underscore('PercentChangeFromYearHigh').to_sym, to_underscore('PercebtChangeFromYearHigh').to_sym)

    def self.fields
      FIELDS
    end

    def initialize(data)
      if data['ErrorIndicationreturnedforsymbolchangedinvalid']
        @no_data_message = data['ErrorIndicationreturnedforsymbolchangedinvalid']
        @response_code = 404
      elsif data['diagnostics'] && data['diagnostics']['warning']
        @no_data_message = data['diagnostics']['warning']
        @response_code = 404
      elsif data['count'] && data['count'] == 0
        @no_data_message = 'Query returns no valid data'
        @response_code = 404
      else
        @response_code = 200
        data.map do |k, v|
          instance_variable_set("@#{to_underscore(k)}", (v.nil? ? nil : to_format(v)))
        end
      end
    end

    def success?
      warn "[DEPRECATION] `Stock#success?` is deprecated.  Please use `NoDataForStockError` instead."
      response_code == 200
    end

    def failure?
      warn "[DEPRECATION] `Stock#failure?` is deprecated.  Please use `NoDataForStockError` instead."
      response_code == 404
    end

    def self.quote(symbol, start_date = nil, end_date = nil, select = '*', format = 'instance')
      url = 'https://query.yahooapis.com/v1/public/yql?q='
      select = format_select(select)
      if start_date && end_date
        url += URI.encode("SELECT #{ select } FROM yahoo.finance.historicaldata WHERE symbol IN (#{to_p(symbol)}) AND startDate = '#{start_date}' AND endDate = '#{end_date}'")
      else
        url += URI.encode("SELECT #{ select } FROM yahoo.finance.quotes WHERE symbol IN (#{to_p(symbol)})")
      end
      url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
      RestClient::Request.execute(:url => url, :method => :get, :verify_ssl => false) do |response|
        if response.code == 200
          parse(response, symbol, format)
        else
          warn "[BAD REQUEST] #{ url }"
          NoDataForStockError.new
        end
      end
    end

    def self.json_quote(symbol, start_date = nil, end_date = nil, select = '*', format = 'json')
      quote(symbol, start_date, end_date, select, format)
    end

    def self.format_select(select)
      return select if select.is_a?(String) && !!('*'.match(/\*/))
      select = select.split(',') if select.is_a?(String)
      select = select.reject{ |e| !(FIELDS.include? e) }
      select.length > 0 ? select.join(',') : '*'
    end

    def self.simple_return(symbol, start_date = Date.parse('2012-01-01'), end_date = Date.today)
      start, finish = to_date(start_date), to_date(end_date)
      raise ArgumentError.new('start dt after end dt') if start > finish

      quotes = []
      begin
        year_quotes = quote(
          symbol,
          start,
          min_date(finish, start + 365),
          'Close'
        )
        if year_quotes.is_a?(Array)
          quotes += year_quotes
        else
          return 0
        end
        start += 365
      end until finish - start < 365
      quotes
      sell = quotes.first.close
      buy = quotes.last.close
      ((sell - buy) / buy) * 100
    end

    def self.parse(json, symbol, format='instance')
      results = []
      json = JSON.parse(json).fetch('query')
      count = json['count']
      raise NoDataForStockError.new(json) if count == 0
      return json['results'] if !!(format=='json')

      data = json['results']['quote']
      data = count == 1 ? [data] : data
      data.each do |d|
        d['symbol'] = to_p(symbol) unless d['symbol']
        stock = Stock.new(d)
        return stock if count == 1
        results << stock
      end

      results
    end

    def self.history(symbol, start_date = '2012-01-01', end_date = Date.today, select = '*', format = 'instance')
      start, finish = to_date(start_date), to_date(end_date)
      raise ArgumentError.new('start dt after end dt') if start > finish

      quotes = []
      begin
        quote = quote(symbol, start, min_date(finish, start + 365), select, format)
        quotes += !!(format=='json') ? quote['quote'] : Array(quote)
        start += 365
      end until finish - start < 365
      return !!(format=='json') ? { 'quote' => quotes } : quotes

    rescue NoDataForStockError => e
      return e
    end

    def self.json_history(symbol, start_date = '2012-01-01', end_date = Date.today, select = '*', format = 'json')
      history(symbol, start_date, end_date, select, format)
    end
  end
end
