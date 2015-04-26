
require 'date'
module StockQuote
  # => StockQuote Utility Methods
  module Utility

    def min_date(first, second)
      first < second ? first : second
    end

    def to_format(string)
      to_fs(to_date(string))
    end

    def to_underscore(string)
      string = string.gsub(/::/, '/')
      string.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      string.tr!('-', '_')
      string.downcase!
      string
    end

    def to_fs(string)
      (!!Float(string) rescue false) ? Float(string) : string
    end

    def to_p(string)
      if string.is_a?(String)
        to_p(string.split(','))
      elsif string.is_a?(Array)
        "'#{string.join("','").gsub(" ", "").upcase}'"
      else
        string
      end
    end

    def to_date(string)
      if string.is_a?(String) && string.match(/\d{4}-\d{2}-\d{2}/)
        Date.strptime(string, '%Y-%m-%d')
      elsif string.is_a?(String) && string.match(/\d{2}\/\d{2}\/\d{4}/)
        Date.strptime(string, '%m/%d/%Y')
      else
        string
      end
    end
  end
end
