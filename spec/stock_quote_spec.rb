require 'stock_quote'
require 'spec_helper'

describe StockQuote::Stock do
  describe 'quote' do
    context 'success' do
      describe 'single symbol' do

        @fields = StockQuote::Stock::FIELDS

        use_vcr_cassette 'aapl'

        @fields.each do |field|
          it ".#{to_underscore(field)}" do
            @stock = StockQuote::Stock.quote('aapl')
            @stock.should respond_to(to_underscore(field).to_sym)
          end

          it ".#{field}" do
            @stock = StockQuote::Stock.quote('aapl')
            @stock.should respond_to(field.to_sym)
          end
        end

        it 'should use underscore getter method for the underscore instance variable' do
          @stock = StockQuote::Stock.new({ 'AdjClose' => 123 })
          expect(@stock.adj_close).to eq(123)
          expect(@stock.AdjClose).to eq(123)
        end

        it 'should result in a successful query with ' do
          @stock = StockQuote::Stock.quote('aapl')
          @stock.response_code.should be_eql(200)
          @stock.should respond_to(:no_data_message)
          @stock.no_data_message.should be_nil
        end

        describe "should select specific fields" do
          it "as string" do
            @stock = StockQuote::Stock.quote('aapl', nil, nil, 'Symbol,Ask,Bid')
            @stock.response_code.should be_eql(200)
            @stock.should respond_to(:no_data_message)
            @stock.no_data_message.should be_nil
          end

          it "as array" do
            @stock = StockQuote::Stock.quote('aapl', nil, nil, ['Symbol','Ask','Bid'])
            @stock.response_code.should be_eql(200)
            @stock.should respond_to(:no_data_message)
            @stock.no_data_message.should be_nil
          end
        end
      end
    end

    describe 'comma seperated symbols' do

      use_vcr_cassette 'aapl,tsla'

      it 'should result in a successful query' do
        @stocks = StockQuote::Stock.quote('aapl,tsla')
        @stocks.each do |stock|
          stock.response_code.should be_eql(200)
          stock.should respond_to(:no_data_message)
          stock.no_data_message.should be_nil
        end
      end
    end

    context 'failure' do

      @fields = StockQuote::Stock::FIELDS

      use_vcr_cassette 'asdf'

      it 'should fail... gracefully if no data is found for that ticker' do
        @stock = StockQuote::Stock.quote('asdf')
        @stock.response_code.should be_eql(404)
        @stock.should respond_to(:no_data_message)
        @stock.no_data_message.should_not be_nil
      end

      it 'should fail... gracefully if the request errors out' do
        stock = StockQuote::Stock.quote('\/')
        expect(stock.response_code).to eql(404)
        expect(stock).to be_instance_of(StockQuote::NoDataForStockError)
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

      it 'succesfuly queries history by default (no start date given' do
        @stock = StockQuote::Stock.history(
          'aapl',
          Date.parse('20130103'),
          Date.parse('20130103')
        )
        expect(@stock.count).to be == 1
      end
    end

    context 'failure' do
      use_vcr_cassette 'asdf_history'

      it 'should not result in a successful query' do
        stock = StockQuote::Stock.history('asdf')
        expect(stock.response_code).to eq(404)
        expect(stock).to respond_to(:no_data_message)
        expect(stock.no_data_message).not_to be_nil
      end

      it 'should raise ArgumentError if start date is after end date' do
        expect do
          s = StockQuote::Stock.history('aapl', Date.today + 2, Date.today)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'json' do
    context 'success' do
      describe 'single symbol' do

        use_vcr_cassette 'aapl'

        it "it should return json" do
          @stock = StockQuote::Stock.json_quote('aapl')
          @stock.is_a?(Hash).should be_true
          @stock.should include('quote')
        end

        describe "should select specific fields" do
          it "as string" do
            @stock = StockQuote::Stock.json_quote('aapl', nil, nil, 'Symbol,Ask,Bid')
            @stock.is_a?(Hash).should be_true
            @stock.should include('quote')
          end

          it "as array" do
            @stock = StockQuote::Stock.json_quote('aapl', nil, nil, ['Symbol','Ask','Bid'])
            @stock.is_a?(Hash).should be_true
            @stock.should include('quote')
          end
        end
      end

      describe 'comma seperated symbols' do

        use_vcr_cassette 'aapl,tsla'

        it 'should result in a successful query' do
          @stocks = StockQuote::Stock.json_quote('aapl,tsla')
          @stocks.is_a?(Hash).should be_true
          @stocks.should include('quote')
        end
      end
      describe 'history' do
        use_vcr_cassette 'aapl_history'

        it 'should result in a successful query' do
          @stock = StockQuote::Stock.json_history('aapl', Date.today - 20)
          @stock.is_a?(Hash).should be_true
          @stock.should include('quote')
        end
      end
    end
  end

  describe 'simple_return' do
    context 'success' do
      use_vcr_cassette 'aapl_simple_return'

      it 'should result in a successful query' do
        simple_return = StockQuote::Stock.simple_return(
          'aapl',
          Date.parse('2012-01-03'),
          Date.parse('2012-01-20')
        )
        expect(simple_return).to eq(2.205578386790845)
      end

      it 'should return 0 if only one price is found' do
        simple_return = StockQuote::Stock.simple_return(
          'TSTA',
          Date.parse('20130201'),
          Date.parse('20130501')
        )
        expect(simple_return).to eq(0)
      end
    end

    context 'failure' do
      use_vcr_cassette 'asdf_simple_return'

      it 'should not result in a successful query' do
        expect do
          stock = StockQuote::Stock.simple_return(
            'asdf',
            Date.parse('2012-01-03'),
            Date.parse('2012-01-20')
          )
        end.to raise_exception
      end

      it 'should raise ArgumentError if start date is after end date' do
        expect do
          s = StockQuote::Stock.simple_return('aapl', Date.today + 2, Date.today)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
