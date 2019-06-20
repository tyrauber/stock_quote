require 'stock_quote'
require 'spec_helper'

describe StockQuote::Stock do

  before(:all) do
    StockQuote::Stock.new(api_key: ENV['API_KEY'])
  end

  StockQuote::Stock::TYPES.each do |key|
    describe key, vcr: { cassette_name: key} do
      let(:range){
        ['dividends', 'splits'].include?(key) ? StockQuote::Stock::RANGES.shuffle.shift : nil
      }
      it "should be instance of Stock" do
        @stock = StockQuote::Stock.send(key, 'aapl', range)
        expectation(@stock)
      end

      it "should be raw json hash" do
        @stock = StockQuote::Stock.send("raw_#{key}", 'aapl', range)
        expectation(@stock, 'json')
      end
    end
  end

  describe '#query' do
    describe 'single action' do
      describe 'single symbol string', vcr: { cassette_name: "aapl"} do

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote','aapl')
          expectation(@stock)
        end

        it "should be json" do
          @stock = StockQuote::Stock.batch('quote','aapl',nil, 'json')
          expectation(@stock, 'json')
        end
      end

      describe 'multiple symbol array', vcr: { cassette_name: "aapl,tsla"} do

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote',['aapl', 'tsla'])
          expectation(@stock)
        end

        it "should be json" do
          @stock = StockQuote::Stock.batch('quote',['aapl', 'tsla'], nil, 'json')
          expectation(@stock, 'json')
        end
      end

      describe 'multiple symbol string', vcr: { cassette_name: "aapl,tsla"} do

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote','aapl,tsla')
          expectation(@stock)
        end

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote','aapl,tsla', nil, 'json')
          expectation(@stock, 'json')
        end
      end
    end
    describe 'multiple action' do
      describe 'multiple symbol array', vcr: { cassette_name: "aapl,tsla"} do

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch(['quote','chart'],['aapl', 'tsla'])
          expectation(@stock)
        end

        it "should be json" do
          @stock = StockQuote::Stock.batch(['quote','chart'],['aapl', 'tsla'], nil, 'json')
          expectation(@stock, 'json')
        end
      end

      describe 'multiple symbol string', vcr: { cassette_name: "aapl,tsla"} do

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote,chart','aapl,tsla')
          expectation(@stock)
        end

        it "should be instance of Stock" do
          @stock = StockQuote::Stock.batch('quote,chart','aapl,tsla', nil, 'json')
          expectation(@stock, 'json')
        end
      end
    end
  end

  protected
  
  def expectation(stock, fmt=nil)
    if stock.is_a?(Array)
      stock.each{|s| expectation(s, fmt) }
    elsif fmt=='json'
      expect(stock).to be_an_instance_of(Hash)
    else
      expect(stock).to be_an_instance_of(StockQuote::Stock)
      expect(stock).to respond_to(:symbol)
      expect(stock).to respond_to(:response_code)
      expect(stock).to respond_to(:attribution)
      expect(stock.attribution).to be(StockQuote::Stock::ATTRIBUTION)
    end
  end
end