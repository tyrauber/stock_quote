require 'date'
class String

  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def to_fs
    (!!Float(self) rescue false) ? Float(self) : self
  end

  def to_p
    self.split(',').to_p
  end

  def to_date
    if self.match(/\d{4}-\d{2}-\d{2}/)
      Date.strptime(self, "%Y-%m-%d").to_s
    elsif self.match(/\d{2}\/\d{2}\/\d{4}/)
      Date.strptime(self, "%m/%d/%Y").to_s
    else
      self
    end
  end
end
class Array
  def to_p
    "'#{self.join("','").gsub(" ", "").upcase}'"
  end
  def success?
    !!(!self.empty? && self.first.respond_to?(:success?) && self.first.success?)
  end
end