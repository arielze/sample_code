class DataObject < BasicObject

  def initialize(data)
    data.each_pair do |att, value| 
      #(class << self ; self ; end) to access the 'singleton class'
      (class << self ; self ; end).send(:define_method, att, ->{value})
    end
  end

end
