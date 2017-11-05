# stock_quote

A ruby gem that retrieves stock quotes and historical pricing from ~~google~~ ~~yahoo~~...

# Update

On November 1st, 2017, Yahoo Finance terminated public access to the API:

`It has come to our attention that this service is being used in violation of the Yahoo Terms of Service.  As such, the service is being discontinued.  For all future markets and equities data research, please refer to finance.yahoo.com.`

As a result, the stock_quote gem ceases to function in it's current state.

Solutions are welcome.

## Installation

To install the 'stock_quote' ruby gem:

`gem install stock_quote`

## Gem Configuration

To use the gem in your Rails Application, include it:

### Rails 2+

Include the gem in config/environments.rb:

`config.gem "stock_quote"`

### Rails 3+

Include the gem in your Gemfile:

`gem "stock_quote"`

## Usage

### StockQuote::Stock.quote("symbol")

You can get a current quote with the following syntax:

`stock = StockQuote::Stock.quote("symbol")`

Where symbol equals the company stock symbol you want a quote for. For example, "aapl" for Apple, Inc.

You may search for multiple stocks by separating symbols with a comma. For example:

`stocks = StockQuote::Stock.quote("aapl,tsla")`

Or as an array.

`stocks = StockQuote::Stock.quote(["aapl", "tsla"])`

These queries will return a Stock object or an array of Stock objects which you may iterate through. 

Each stock object has the following values:

`symbol, ask, average_daily_volume, bid, ask_realtime, bid_realtime, book_value, change_percent_change, change, commission, change_realtime, after_hours_change_realtime, dividend_share, last_trade_date, trade_date, earnings_share, error_indicationreturnedforsymbolchangedinvalid, eps_estimate_current_year, eps_estimate_next_year, eps_estimate_next_quarter, days_low, days_high, year_low, year_high, holdings_gain_percent, annualized_gain, holdings_gain, holdings_gain_percent_realtime, holdings_gain_realtime, more_info, order_book_realtime, market_capitalization, market_cap_realtime, ebitda, change_from_year_low, percent_change_from_year_low, last_trade_realtime_with_time, change_percent_realtime, change_from_year_high, percent_change_from_year_high, last_trade_with_time, last_trade_price_only, high_limit, low_limit, days_range, days_range_realtime, fiftyday_moving_average, two_hundredday_moving_average, change_from_two_hundredday_moving_average, percent_change_from_two_hundredday_moving_average, change_from_fiftyday_moving_average, percent_change_from_fiftyday_moving_average, name, notes, open, previous_close, price_paid, changein_percent, price_sales, price_book, ex_dividend_date, pe_ratio, dividend_pay_date, pe_ratio_realtime, peg_ratio, price_eps_estimate_current_year, price_eps_estimate_next_year, symbol, shares_owned, short_ratio, last_trade_time, ticker_trend, oneyr_target_price, volume, holdings_value, holdings_value_realtime, year_range, days_value_change, days_value_change_realtime, stock_exchange, dividend_yield, percent_change, error_indicationreturnedforsymbolchangedinvalid, date, open, high, low, close, adj_close`

Additionally, CamelCase method aliases exist for each attribute.

### Symbol Lookup

StockQuote (version 1.3.0) now provides the ability to lookup a stock symbol by company name.

`symbols = StockQuote::Symbol.lookup('apple')`

Or limited to specific exchange:

`symbols = StockQuote::Symbol.lookup('apple', ['NYQ'])`

Symbol lookup returns the following attributes:

`symbol, name, exch, type, exchDisp, typeDisp`

### Field Selection

By supplying a select parameter you may query only specific fields. Supplying nil as the start_date and end_date will return the last market quote.  The select parameter can either by a comma separated string of field names, or an array of field names.

For example, to query the Symbol, Ask and Bid for AAPL:

`stocks = StockQuote::Stock.quote('aapl', nil, nil, ['Symbol', 'Ask', 'Bid'])`

You may also query multiple symbols:

`stocks = StockQuote::Stock.quote(['aapl', 'tsla'], nil, nil, ['Symbol', 'Ask', 'Bid'])`

### Format

If you prefer raw json as opposed to Stock instances, you may use the following convenience methods:

`stocks = StockQuote::Stock.json_quote('aapl')`

`stocks = StockQuote::Stock.json_history('aapl')`

All other options are also available.


## Response Codes

Stock instances now include a response_code: 200 and 404.

    > @stock = StockQuote::Stock.quote('aapl')
    > @stock.response_code
      => 200

Additionally, stock instances now have a success? and failure? method.

    > @stock.success?
      => true

In the event that a stock symbol is incorrect, the returned instance will provide a response code of 404 and respond in the affirmative to a failure? method call.

    > @stock = StockQuote::Stock.quote('asdf')
    > @stock.response_code
      => 404
    > @stock.failure?
      => true

Response codes and success failure methods are not available with json responses.

## License

Copyright (c) 2011 Ty Rauber

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

