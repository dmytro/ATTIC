shared_examples_for "UNIX networking" do

  require 'ostruct'
  require 'pp'

  data = nil
  
  before(:each) do
    
    Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
    Uliska::Parser.load_parsers
    data = OpenStruct.new Uliska::Parser.data
    
  end

  context "network interfaces" do 


    it "should have name" do 
      pending
    end

    it "at least 1 should be configured" do 
      pending
    end

    it "at least 1 should be UP" do 
      pending
    end

    context "configured inteface" do

      it "should have an IP" do 
        pending
      end
      
      it "should have netmask" do 
        pending
      end

      context "local interface" do 
        
        it "should be configured" do 
          pending
        end

        it "IP == 127.0.0.1" do 
          pending
        end

      end                       # local interface
    end                         # configured inteface
  end                           # network inteface

  context "routing" do 
    
    it "should have default route" do 
      pending
    end

    context "each route" do

      it "should have destination" do 
        pending
      end

      it "should have destination" do 
        pending
      end

      it "should have gateway" do 
        pending
      end

      it "should have mask" do 
        pending
      end

      it "should have interface" do 
        pending
      end

    end                         # each route

  end                           # routing
end
