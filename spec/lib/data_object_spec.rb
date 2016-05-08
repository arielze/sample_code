require 'spec_helper'
require './lib/data_object'

describe DataObject do
  context "#initialize" do
    it "should map all attributes" do
      time = Time.now
      atts = { a: 1, b: "test", c: time }
      dobj = DataObject.new  atts
      #dobj.define_attr atts
      expect(dobj.a).to eq 1
      expect(dobj.b).to eq "test"
      expect(dobj.c).to eq time
    end
  end
end
