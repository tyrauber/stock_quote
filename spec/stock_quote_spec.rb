require "stock_quote"

describe StockQuote::Stock do
    companies = [["aapl", "Apple, Inc."], ["goog", "Google Inc."]]
    for c in companies
        puts "Getting a stock quote "+c[1].to_s
        symbol = c[0]
        stock = StockQuote::Stock.quote(symbol)
        it c[0].to_s+" is company "+c[1].to_s do            
            stock.company.should eql(c[1])
        end
        puts stock.inspect
    end
end
