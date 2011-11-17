# stock_quote

A ruby gem that retrieves real-time stock quotes from google.

Retrieve up to 100 stock quotes per query with the following variables - symbol, pretty_symbol, symbol_lookup_url, company, exchange, exchange_timezone, exchange_utc_offset, exchange_closing, divisor, currency, last, high, low, volume, avg_volume, market_cap, open, y_close, change, perc_change, delay, trade_timestamp, trade_date_utc, trade_time_utc, current_date_utc, current_time_utc, symbol_url, chart_url, disclaimer_url, ecn_url, isld_last, isld_trade_date_utc, isld_trade_time_utc, brut_last, brut_trade_date_utc, brut_trade_time_utc and daylight_savings - per stock.

Uses an undocumented Google API, as referenced here:  http://www.jarloo.com/google-stock-api/

"It’s not very well known and Google has no support or docs for it, but there is an elusive Google Stock API. Like most of Google’s API’s it’s REST based. (I wish all API’s were, as I hate SOAP)
API Url Formatting. The API from what I can tell is very simple. It only has a single parameter that accepts a stock ticker."

## Installation

To install the stock quote ruby gem:

`gem install stock_quote`

## Include

To use the gem in your Rails Application, include it:

### Rails 2+

Include the gem in config/environments.rb:

`config.gem "stock_quote"`

### Rails 3+

Include the gem in your Gemfile:

`gem "stock_quote"`

## Instructions

To use the stock_quote gem, you can get a quote with the following syntax:

`stock = StockQuote::Stock.find("symbol")`

Where symbol equals the company stock symbol you want a quote for. For example, "aapl" for Apple, Inc.

You may search for multiple stocks by seperating symbols with a comma. For example:

`stocks = StockQuote::Stock.find("aapl, google")`

These queries will return a Stock object or an array of Stock objects which you may iterate through. Each stock object has the following values:

* symbol
* pretty_symbol
* symbol_lookup_url
* company
* exchange
* exchange_timezone
* exchange_utc_offset
* exchange_closing
* divisor
* currency
* last
* high
* low
* volume
* avg_volume
* market_cap
* open
* y_close
* change
* perc_change
* delay
* trade_timestamp
* trade_date_utc
* trade_time_utc
* current_date_utc
* current_time_utc
* symbol_url
* chart_url
* disclaimer_url
* ecn_url
* isld_last
* isld_trade_date_utc
* isld_trade_time_utc
* brut_last
* brut_trade_date_utc
* brut_trade_time_utc
* daylight_savings

These values may be accessed off the Stock object like so:

`stock.last`

You can always convert the queries results to json with the following commands:

`stock.to_json`

Or for multiple quote queries:

`stocks.to_json`

## Special thanks to

...Google for making this api publically available. I found the Google Finance API to be overly complex for simple stock quote queries.

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

