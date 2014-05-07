require 'rubygems'
require 'rest-client'
require 'json'
require 'date'

module StockQuote
  # => SecQuote::NoDataForStockError
  # Is returned for 404s and ErrorIndicationreturnedforsymbolchangedinvalid
  class NoDataForStockError < StandardError
    attr_reader :no_data_message
    def initialize(data, *)
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
    FIELDS = %w(symbol Ask AverageDailyVolume Bid AskRealtime BidRealtime BookValue Change_PercentChange Change Commission ChangeRealtime AfterHoursChangeRealtime DividendShare LastTradeDate TradeDate EarningsShare ErrorIndicationreturnedforsymbolchangedinvalid EPSEstimateCurrentYear EPSEstimateNextYear EPSEstimateNextQuarter DaysLow DaysHigh YearLow YearHigh HoldingsGainPercent AnnualizedGain HoldingsGain HoldingsGainPercentRealtime HoldingsGainRealtime MoreInfo OrderBookRealtime MarketCapitalization MarketCapRealtime EBITDA ChangeFromYearLow PercentChangeFromYearLow LastTradeRealtimeWithTime ChangePercentRealtime ChangeFromYearHigh PercebtChangeFromYearHigh LastTradeWithTime LastTradePriceOnly HighLimit LowLimit DaysRange DaysRangeRealtime FiftydayMovingAverage TwoHundreddayMovingAverage ChangeFromTwoHundreddayMovingAverage PercentChangeFromTwoHundreddayMovingAverage ChangeFromFiftydayMovingAverage PercentChangeFromFiftydayMovingAverage Name Notes Open PreviousClose PricePaid ChangeinPercent PriceSales PriceBook ExDividendDate PERatio DividendPayDate PERatioRealtime PEGRatio PriceEPSEstimateCurrentYear PriceEPSEstimateNextYear Symbol SharesOwned ShortRatio LastTradeTime TickerTrend OneyrTargetPrice Volume HoldingsValue HoldingsValueRealtime YearRange DaysValueChange DaysValueChangeRealtime StockExchange DividendYield PercentChange ErrorIndicationreturnedforsymbolchangedinvalid Date Open High Low Close AdjClose)

    attr_accessor :response_code, :no_data_message

    FIELDS.each do |field|
      __send__(:attr_accessor, field.underscore.to_sym)
    end

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
          instance_variable_set("@#{k.underscore}", (v.nil? ? nil : v.to_date.to_fs))
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

    def self.quote(symbol, start_date = nil, end_date = nil)
      url = 'https://query.yahooapis.com/v1/public/yql?q='
      if start_date && end_date
        url += URI.encode("SELECT * FROM yahoo.finance.historicaldata WHERE symbol IN (#{symbol.to_p}) AND startDate = '#{start_date}' AND endDate = '#{end_date}'")
      else
        url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{symbol.to_p})")
      end
      url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
      response = RestClient.get(url)

      parse(response, symbol)
    end

    def self.parse(json, symbol)
      results = []
      json = JSON.parse(json).fetch('query')
      count = json['count']
      raise NoDataForStockError.new(json) if count == 0
      data = json['results']['quote']
      data = count == 1 ? [data] : data

      data.each do |d|
        d['symbol'] = symbol.to_p unless d['symbol']
        stock = Stock.new(d)
        return stock if count == 1
        results << stock
      end

      results
    end

    def self.history(symbol, start_date = '2012-01-01', end_date = Date.today)
      start, finish = Date(start_date), Date(end_date)
      raise ArgumentError.new('start dt after end dt') if start > finish

      quotes = []
      begin
        quotes += quote(symbol, start, Date.min(finish, start + 365))
        start += 365
      end until finish - start < 365
      quotes

    rescue NoDataForStockError => e
      return e
    end
  end
end
