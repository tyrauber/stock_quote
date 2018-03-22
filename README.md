# stock_quote

Real-time, stock data and historical pricing. Data provided for free by [IEX](https://iextrading.com/developer/).

# Update

On March 17, 2018, Google Finance terminated public access to it's API.  As a result, previous versions of stock_quote ceased to fuuntion. Therefore, Version 2.0.0 of stock_quote now uses the IEX Trading API (iextrading.com). Although some functionalility is similar, the results, and therefore attributes, had changed. Please review the doumentation below and update accordingly. 

## Installation

To install the 'stock_quote' ruby gem:

`gem install stock_quote`

## Gem Configuration

To use the gem in your Rails Application, include it in your Gemfile:

`gem "stock_quote"`, '~> 2.0.0'

### StockQuote::Stock.quote(symbol)

Quote is the primary method, returning a StockQuote::Stock instance, including the following attributes (new in v2.0.0).

`symbol, company_name, primary_exchange, sector, calculation_price, open, open_time, close, close_time, high, low, latest_price, latest_source, latest_time, latest_update, latest_volume, iex_realtime_price, iex_realtime_size, iex_last_updated, delayed_price, delayed_price_time, previous_close, change, change_percent, iex_market_percent, iex_volume, avg_total_volume, iex_bid_price, iex_bid_size, iex_ask_price, iex_ask_size, market_cap, pe_ratio, week52_high, week52_low, ytd_change, chart`

You can get a current quote with the following syntax:

`stock = StockQuote::Stock.quote("symbol")`

Where symbol equals the company stock symbol you want a quote for. For example, "aapl" for Apple, Inc.

You may search for multiple stocks by separating symbols with a comma (or array). For example:

`stocks = StockQuote::Stock.quote("aapl,tsla")`

These queries will return a Stock object or an array of Stock objects which you may iterate through. 

Note: You can receive a raw json hash response with the following syntax:

`stocks = StockQuote::Stock.raw_quote("aapl,tsla")`

The raw_ method is available on all supported methods.

### Other Methods

The IEX API is quite extensive and well documented.

V2.0.0 of stock_quote mirrors the IEX API:

* [book](https://iextrading.com/developer/docs/#book)
* [chart](https://iextrading.com/developer/docs/#chart)
* [company](https://iextrading.com/developer/docs/#company)
* [delayed_quote](https://iextrading.com/developer/docs/#delayed-quote)
* [dividends](https://iextrading.com/developer/docs/#dividends)
* [earnings](https://iextrading.com/developer/docs/#earnings)
* [effective_spread](https://iextrading.com/developer/docs/#effective-spread)
* [financials](https://iextrading.com/developer/docs/#financials)
* [stats](https://iextrading.com/developer/docs/#key-stats)
* [logo](https://iextrading.com/developer/docs/#logo)
* [news](https://iextrading.com/developer/docs/#news)
* [ohlc](https://iextrading.com/developer/docs/#ohlc)
* [peers](https://iextrading.com/developer/docs/#peers)
* [previous](https://iextrading.com/developer/docs/#previous)
* [price](https://iextrading.com/developer/docs/#price)
* [quote](https://iextrading.com/developer/docs/#quote)
* [relevant](https://iextrading.com/developer/docs/#relevant)
* [splits](https://iextrading.com/developer/docs/#splits)
* [volume_by_venue](https://iextrading.com/developer/docs/#volume-by-venue)

All these methods are available on StockQuote::Stock.

For example:

```StockQuote::Stock.company('aapl')`

Retrieves company information.

For example:

```StockQuote::Stock.dividends('aapl')`

Retrieves dividend information.

Raw json hash responses are available for any of the methods by pre-fixing the method name with "raw__".

For example:

```StockQuote::Stock.raw_dividends('aapl')`

Retrieves raw dividend information.

### [batch](https://iextrading.com/developer/docs/#batch-requests)

Batch allows you to batch requests.  All methods in stock_quote use batch under-the-hood.

Batch follows the syntax:

`StockQuote::Stock.batch(type, symbol, range)`

Where type can be multiple of the above methods and symbol can be an array of company symbols.

Range can be:

`5y, 2y, 1y, ytd, 6m, 3m, 1m, 1d

And are applied to chart method.

#### TBD

The following IEX methods are currently unsupported:

* [list](https://iextrading.com/developer/docs/#list)
  * mostactive
  * gainers
  * losers
  * iexvolume
  * iexvolume
* [threshold_securities](https://iextrading.com/developer/docs/#iex-regulation-sho-threshold-securities-list)
* [short_interest](https://iextrading.com/developer/docs/#iex-short-interest-list)


## Special thanks to

IEX for making this api publicly available.


## License

Copyright (c) 2018 Ty Rauber

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
