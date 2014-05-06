require 'date'

class Array
  def to_p
    "'#{join("','").gsub(" ", "").upcase}'"
  end

  def success?
    !!(!self.empty? && first.respond_to?(:success?) && first.success?)
  end
end

def Date(arg)
  return arg if arg.is_a?(Date)
  Date.parse(arg) if arg.is_a?(String)
end

class String
  def underscore
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
    gsub(/([a-z\d])([A-Z])/, '\1_\2').
    tr('-', '_').
    downcase
  end

  def to_fs
    (!!Float(self) rescue false) ? Float(self) : self
  end

  def to_p
    split(',').to_p
  end

  def to_date
    if match(/\d{4}-\d{2}-\d{2}/)
      Date.strptime(self, '%Y-%m-%d').to_s
    elsif match(/\d{2}\/\d{2}\/\d{4}/)
      Date.strptime(self, '%m/%d/%Y').to_s
    else
      self
    end
  end
end
