require 'stock_quote'
require 'spec_helper'

describe StockQuote::Stock do
  describe 'quote' do
    context 'success' do
      describe 'single symbol', vcr: { cassette_name: "aapl"} do

        @fields = StockQuote::Stock::FIELDS

        @fields.each do |field|
          it ".#{to_underscore(field)}" do
            @stock = StockQuote::Stock.quote('aapl')
            expect(@stock).to respond_to(to_underscore(field).to_sym)
          end

          it ".#{field}" do
            @stock = StockQuote::Stock.quote('aapl')
            expect(@stock).to respond_to(field.to_sym)
          end
        end

        it 'should use underscore getter method for the underscore instance variable' do
          @stock = StockQuote::Stock.new({ 'Symbol' => 'aapl', 'Open' => '123', 'AdjClose' => 123 })
          expect(@stock.symbol.length).to eq(4)
          expect(@stock.adj_close).to eq(123)
          expect(@stock.AdjClose).to eq(123)
        end

        it 'should result in a successful query with symbol' do
          @stock = StockQuote::Stock.quote('aapl')
          expect(@stock.response_code).to be_eql(200)
          expect(@stock.symbol.length).to eq(4)
          expect(@stock).to respond_to(:no_data_message)
          expect(@stock.no_data_message).to be_nil
        end

        describe "should select specific fields" do
          it "as string" do
            @stock = StockQuote::Stock.quote('aapl', nil, nil, 'Symbol,Ask,Bid')
            expect(@stock.response_code).to be_eql(200)
            expect(@stock.symbol.length).to eq(4)
            expect(@stock).to respond_to(:no_data_message)
            expect(@stock.no_data_message).to be_nil
          end

          it "as array" do
            @stock = StockQuote::Stock.quote('aapl', nil, nil, ['Symbol','Ask','Bid'])
            expect(@stock.response_code).to be_eql(200)
            expect(@stock.symbol.length).to eq(4)
            expect(@stock).to respond_to(:no_data_message)
            expect(@stock.no_data_message).to be_nil
          end
        end
      end
    end

    describe 'comma seperated symbols', vcr: { cassette_name: "aapl,tsla"} do

      it 'should result in a successful query' do
        @stocks = StockQuote::Stock.quote('aapl,tsla')
        @stocks.each do |stock|
          expect(stock.response_code).to be_eql(200)
          expect(stock.symbol.length).to eq(4)
          expect(stock).to respond_to(:no_data_message)
          expect(stock.no_data_message).to be_nil
        end
      end

      it 'should return symbol' do
        @stocks = StockQuote::Stock.quote('aapl,tsla',nil, nil, ['Symbol', 'LastTradePriceOnly'])
        @stocks.each do |stock|
          expect(stock.symbol.length).to eq(4)
          expect(stock.response_code).to be_eql(200)
          expect(stock).to respond_to(:no_data_message)
          expect(stock.no_data_message).to be_nil
        end
      end
    end

    context 'failure', vcr: { cassette_name: "asdf"} do

      @fields = StockQuote::Stock::FIELDS

      it 'should fail... gracefully if no data is found for that ticker' do
        @stock = StockQuote::Stock.quote('asdf')
        expect(@stock.response_code).to be_eql(404)
        expect(@stock).to respond_to(:no_data_message)
        expect(@stock.no_data_message).to_not be_nil
      end

      it 'should fail... gracefully if the request errors out' do
        stock = StockQuote::Stock.quote('\/')
        expect(stock.response_code).to eql(404)
        expect(stock).to be_instance_of(StockQuote::NoDataForStockError)
      end
    end
  end

  describe 'history', vcr: { cassette_name: 'aapl_history'} do
    it 'should raise API Change Error' do
      expect do
        s = StockQuote::Stock.history('aapl', Date.today, Date.today+2)
      end.to raise_error(StockQuote::ApiChange)
    end
  end

  describe 'json' do
    context 'success' do
      describe 'single symbol', vcr: { cassette_name: 'aapl'} do

        it "it should return json" do
          @stock = StockQuote::Stock.json_quote('aapl')
          expect(@stock.is_a?(Hash)).to be(true)
          expect(@stock).to include('quote')
        end

        describe "should select specific fields" do
          it "as string" do
            @stock = StockQuote::Stock.json_quote('aapl', nil, nil, 'Symbol,Ask,Bid')
            expect(@stock.is_a?(Hash)).to be(true)
            expect(@stock).to include('quote')
          end

          it "as array" do
            @stock = StockQuote::Stock.json_quote('aapl', nil, nil, ['Symbol','Ask','Bid'])
            expect(@stock.is_a?(Hash)).to be(true)
            expect(@stock).to include('quote')
          end
        end
      end

      describe 'comma seperated symbols', vcr: { cassette_name: 'aapl,tsla'} do

        it 'should result in a successful query' do
          @stocks = StockQuote::Stock.json_quote('aapl,tsla')
          expect(@stocks.is_a?(Hash)).to be(true)
          expect(@stocks).to include('quote')
        end
      end
      describe 'history', vcr: { cassette_name: 'aapl_history'} do

        it 'should raise API Change Error' do
          expect do
            StockQuote::Stock.json_history('aapl', Date.today - 20)
          end.to raise_error(StockQuote::ApiChange)
        end
      end
    end
  end
end
