require 'stock_quote'
require 'spec_helper'

describe 'Date() kernel function' do
  it 'will pass through objects which are already dates' do
    expect(to_date(Date.today)).to eq(Date.today)
  end

  it 'will attempt to convert strings into dates' do
    expect(to_date('2012-01-01')).to eq(Date.parse('2012-01-01'))
  end

  it 'will convert title cased words to underscored words' do
    expect(to_underscore('AdjClose')).to eq('adj_close')
  end

  it 'will raise an invalid Date error if it cannot convert arg into date' do
    expect do
      to_date('abcd').to eq(Date.parse('2012-01-01'))
    end.to raise_error
  end
end

describe Date do
  describe '::min' do
    it 'returns the minimum of two dates passed' do
      expect(min_date(Date.parse('2000-01-01'), Date.parse('2012-01-01')))
        .to eq(Date.parse('2000-01-01'))
    end
  end
end

