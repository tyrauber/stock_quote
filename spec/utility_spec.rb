require 'stock_quote'
require 'spec_helper'

describe 'Date() kernel function' do
  it 'will pass through objects which are already dates' do
    expect(Date(Date.today)).to eq(Date.today)
  end

  it 'will attempt to convert strings into dates' do
    expect(Date('2012-01-01')).to eq(Date.parse('2012-01-01'))
  end

  it 'will raise an invalid Date error if it cannot convert arg into date' do
    expect do
      Date('abcd')
    end.to raise_error
  end
end
