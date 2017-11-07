# stock_quote

Real-time, stock data and historical pricing using the Google Finance API.

# Update

On November 1st, 2017, Yahoo Finance terminated public access to the API and stock_quote ceased to function in it's current state.  Therefore, Version 1.5.0 now utilizes the Google Finance API and although functionally similar, the results, and therefore attributes, have changed. Please update accordingly.

## Installation

To install the 'stock_quote' ruby gem:

`gem install stock_quote`

## Gem Configuration

To use the gem in your Rails Application, include it in your Gemfile:

`gem "stock_quote"`

## Usage

### Quote

You can get a current quote with the following syntax:

`stock = StockQuote::Stock.quote("symbol")`

Where symbol equals the company stock symbol you want a quote for. For example, "aapl" for Apple, Inc.

You may search for multiple stocks by separating symbols with a comma. For example:

`stocks = StockQuote::Stock.quote("aapl,tsla")`

These queries will return a Stock object or an array of Stock objects which you may iterate through. 

Each stock object has the following values:

`symbol, exchange, id, t, e, name, f_reuters_url, f_recent_quarter_date, f_annlyal_date, f_ttm_date, financials, kr_recent_quarter_date, kr_annual_date, kr_ttm_date, c, l, cp, ccol, op, hi, lo, vo, avvo, hi52,  lo52, mc, pe, fwpe, beta, eps, dy, ldiv, shares, instown, eo, sid, sname, iid, iname, related, summary, management, moreresources, events`

Among others.

### History

History is available by providing and start date, or a start date and end date.

`stock = StockQuote::Stock.history("symbol", "start_date", "end_date")`

The stock instance will contain a symbol and history attribute, containing an array of hashes including date, open, high, low, close and volume.

Date format is impressively flexible. 01-Jan-2016, 01-January-2016, January 01, 2016, 01/01/2016, 01-01-2016, 01-01-16 are all accepted.

### Format

If you prefer raw json as opposed to Stock instances, you may use the following convenience methods:

`stocks = StockQuote::Stock.json_quote('aapl')`

`stocks = StockQuote::Stock.json_history('aapl')`

All other options are also available.


## Special thanks to

...~~Google~~ ~~Yahoo~~ Google for making this api publicly available.

## License

Copyright (c) 2017 Ty Rauber

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
