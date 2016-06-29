shared_examples_for "unix with sysctl" do

  require 'ostruct'
  require 'pp'

  data = nil
  
  before(:each) do
    
    Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
    Uliska::Parser.load_parsers
    data = OpenStruct.new Uliska::Parser.data
    
  end

  context "sysctl" do

    it "should exist and be a Hash" do
      data.sysctl.should be_a_kind_of Hash
    end

  end

end
