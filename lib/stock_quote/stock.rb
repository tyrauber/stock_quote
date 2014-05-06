require 'rubygems'
require 'rest-client'
require 'json'
require 'date'

module StockQuote
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
      response_code == 200
    end

    def failure?
      response_code == 404
    end

    def self.quote(symbol, start_date = nil, end_date = nil)
      url = 'http://query.yahooapis.com/v1/public/yql?q='

      if start_date && end_date
        url = url + URI.encode(<<-YQL)
          SELECT
            *
          FROM
            yahoo.finance.historicaldata
          WHERE
            symbol
          IN
            (#{symbol.to_p})
          AND
            startDate = '#{start_date}'
          AND
            endDate = '#{end_date}'
        YQL
      else
        url = url + URI.encode("select * from yahoo.finance.quotes where symbol in (#{symbol.to_p})")
      end
      url = url + '&env=http%3A%2F%2Fdatatables.org%2Falltables.env&format=json'
      response = RestClient.get(url)
      parse(response, symbol)
    end

    def self.parse(json, symbol)
      results = []
      json = JSON.parse(json)
      count = json['query']['count']
      return Stock.new(json['query']) if count == 0
      data = json['query']['results']['quote']
      data = count == 1 ? [data] : data

      for d in data
        d['symbol'] = symbol.to_p unless d['symbol']
        stock = Stock.new(d)
        return stock if count == 1
        results << stock
      end
      results
    end

    def self.history(symbol, start_date = '2012-01-01', end_date = '2013-01-08')
      quote(symbol, start_date, end_date)
    end
  end
end
