$: << File.dirname(File.dirname(__FILE__)) + "/lib"
require "uliska_parser.rb"
require "uliska_parser/extensions"
require "data_structure"

require "#{File.dirname(__FILE__)}/common"

describe "uliska parser" do

    before do 
      @p = Uliska::Parser
    end
  
  context "load data" do

    it "should load YAML data" do
      @p.instance.load %q{
---
a: b
}
      @p.raw[:a].should == "b"
    end

    it "should load YAML file" do
      @p.instance.read "#{DATA_ROOT}/sample_yaml.yml"
      @p.raw[:string].should == "test"
    end

  end
  
  context "colon separated" do

    before do
      @p.instance.load <<-DATA
/etc/passwd:
  - nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false
  - root:*:0:0:System Administrator:/var/root:/bin/sh
  - daemon:*:1:1:System Services:/var/root:/usr/bin/false
DATA
    end

    it "has all fields" do
      data = @p.colon_separated(['a:b:c:d'],%w{f1 f2 f3 f4}).first
      [:f1, :f2, :f3, :f4].each do |key|
        data.should have_key key
      end
    end

    it "has not more then required fields" do
      data = @p.colon_separated(['a:b:c:d'],%w{f1 f2 f3}).first
      [:f1, :f2, :f3].each do |key|
        data.should have_key key
      end
      data.should_not have_key :f4
    end

    it "allow override separator" do
      data = @p.colon_separated(['a:b,c:d'],%w{f1 f2}, ',').first
      data[:f1].should == 'a:b'
    end
    

    it "converts numbers to numeric" do

      @p.colon_separated("/etc/passwd", %w{ user passwd uid gid gecos home shell}).each do |line|
        line[:uid].should be_a_kind_of Numeric
        line[:gid].should be_a_kind_of Numeric
      end
    end
  end

  context "value-key pairs" do

    before do
      @p.instance.load <<DATA
vmstat:
  - '       384636 K total memory'
  - '       194936 K used memory'
  - '        85784 K inactive memory'
  - '         3172 non-nice user cpu ticks'
  - '            0 nice user cpu ticks'
  - '         5009 IO-wait cpu ticks'
  - '          968 IRQ cpu ticks'


DATA
    end
    
    it "values should be numeric" do 
      @p.value_label_pairs(:vmstat).each do |key,value|
        value.should be_a_kind_of Integer
      end
    end

    it "values should properly convert values with K suffix" do 
      @p.value_label_pairs(:vmstat)["total memory"].should == 384636 * 1024
      @p.value_label_pairs(:vmstat)["IRQ cpu ticks"].should == 968
    end

  end
end
