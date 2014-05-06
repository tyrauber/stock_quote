require 'stock_quote'
require 'spec_helper'

describe StockQuote::Stock do
  describe 'quote' do
    context 'success' do
      describe 'single symbol' do

        @fields = StockQuote::Stock::FIELDS

        use_vcr_cassette 'aapl'

        @fields.each do |field|
          it ".#{field}" do
            @stock = StockQuote::Stock.quote('aapl')
            @stock.should respond_to(field.underscore.to_sym)
          end
        end

        it 'should result in a successful query with ' do
          @stock = StockQuote::Stock.quote('aapl')
          @stock.should be_success
          @stock.response_code.should be_eql(200)
          @stock.should respond_to(:no_data_message)
          @stock.no_data_message.should be_nil
        end
      end
    end

    describe 'comma seperated symbols' do

      use_vcr_cassette 'aapl,tsla'

      it 'should result in a successful query' do
        @stocks = StockQuote::Stock.quote('aapl,tsla')
        @stocks.each do |stock|
          stock.should be_success
          stock.response_code.should be_eql(200)
          stock.should respond_to(:no_data_message)
          stock.no_data_message.should be_nil
        end
      end
    end

    context 'failure' do

      @fields = StockQuote::Stock::FIELDS

      use_vcr_cassette 'asdf'

      it 'should fail... gracefully' do
        @stock = StockQuote::Stock.quote('asdf')
        @stock.should be_failure
        @stock.response_code.should be_eql(404)
        @stock.should respond_to(:no_data_message)
        @stock.no_data_message.should_not be_nil
      end
    end
  end

  describe 'history' do
    context 'success' do
      use_vcr_cassette 'aapl_history'

      it 'should result in a successful query' do
        @stock = StockQuote::Stock.history('aapl', Date.today - 20)
        @stock.count.should >= 1
      end

      it 'succesfuly queries history by default (no start date given' do
        @stock = StockQuote::Stock.history('aapl')
        expect(@stock.count).to be >= 1
      end
    end

    context 'failure' do
      use_vcr_cassette 'asdf_history'

      it 'should result in a successful query' do
        stock = StockQuote::Stock.history('asdf')
        expect(stock.response_code).to eq(404)
        expect(stock).to respond_to(:no_data_message)
        expect(stock.no_data_message).not_to be_nil
      end

      it 'should raise ArgumentError if start date is after end date' do
        expect do
          StockQuote::Stock.history('aapl', Date.today + 2, Date.today)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
