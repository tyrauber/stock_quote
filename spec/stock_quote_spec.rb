require 'stock_quote'
require 'spec_helper'

describe StockQuote::Stock do
  describe 'quote' do
    describe 'single symbol', vcr: { cassette_name: "aapl"} do

      before(:all) do
        VCR.use_cassette("aapl") do
          @stock = StockQuote::Stock.quote('aapl')
        end
      end

      it "should be instance of Stock" do
        expect(@stock).to be_an_instance_of(StockQuote::Stock)
      end

      it "should respond to response_code" do
        expect(@stock).to respond_to(:response_code)
      end

      (StockQuote::Stock::FIELDS - %w(f_annlyal_date fwpe eo events)).each do |k|
        it "should respond to #{k}" do
          expect(@stock).to respond_to(k)
          expect(@stock.send(k)).to_not be_nil
          expect(@stock.send(k).length).to be > 0
        end
      end
    end
    describe 'comma seperated symbols', vcr: { cassette_name: 'aapl,tsla'} do

      it 'should result in a successful query' do
        @stocks = StockQuote::Stock.quote('aapl,tsla')
        expect(@stocks.is_a?(Array)).to be(true)
        expect(@stocks.first).to be_an_instance_of(StockQuote::Stock)
      end
    end
  end
  describe 'history', vcr: { cassette_name: "aapl-history"} do
    before(:all) do
      VCR.use_cassette("aapl-history") do
        @stock = StockQuote::Stock.quote('aapl', '01-Jan-2016')
      end
    end

    it 'should respond_to response_code' do
      expect(@stock).to respond_to(:response_code)
    end
    
    it 'should return json' do
      @stock = StockQuote::Stock.quote('aapl', '01-Jan-2016', nil, 'json')
      expect(@stock.is_a?(Hash)).to be(true)
    end
    
    it 'should return multiple quotes' do
      @stock = StockQuote::Stock.quote('aapl,tsla', '01-Jan-2016')
      expect(@stock.first).to respond_to(:response_code)
    end
    
    describe 'versions of date allowed' do
      
      # Wow. Impressive date handling. Nice work, Google.

      it '01-Jan-2016' do
        @stock = StockQuote::Stock.quote('aapl', '01-Jan-2016')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end

      it '01-January-2016' do
        @stock = StockQuote::Stock.quote('aapl', '01-January-2016')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end

      it 'January 01, 2016' do
        @stock = StockQuote::Stock.quote('aapl', 'January 01, 2016')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end

      it '01/01/2016' do
        @stock = StockQuote::Stock.quote('aapl', '01/01/2016')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end
      
      it '01-01-2016' do
        @stock = StockQuote::Stock.quote('aapl', '01-01-2016')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end
      
      it '01-01-16' do
        @stock = StockQuote::Stock.quote('aapl', '01-01-16')
        expect(@stock.history.last[:date]).to eq('4-Jan-16')
      end
    end
  end
end
