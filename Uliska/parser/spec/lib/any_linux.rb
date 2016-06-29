shared_examples_for "any linux" do

  require 'ostruct'
  require 'pp'

  context "any Linux" do

    data = nil

    before(:each) do

      Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
      Uliska::Parser.load_parsers
      data = OpenStruct.new Uliska::Parser.data
      
    end

    it_should_behave_like "any unix"
    it_should_behave_like "unix with sysctl"
    it_should_behave_like "any filesystem"


    it "should have distro name" do 
      data.distro.should be_a_kind_of String
    end

  end
end
