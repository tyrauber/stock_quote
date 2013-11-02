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
end
class Array
  def to_p
    "'#{self.join("','").gsub(" ", "").upcase}'"
  end
end