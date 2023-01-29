class DataFormat
  def self.format(i)
    data = i.gsub!(/\s* | *\"/, "")
    eval(data)
  end
end