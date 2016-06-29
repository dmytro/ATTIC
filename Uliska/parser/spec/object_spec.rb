$: << File.dirname(File.dirname(__FILE__)) + "/lib"
require "uliska_parser/extensions"

describe String do

  it "not string should return self" do
    nil.to_num.should == nil
    [].to_num.should == []
    { }.to_num.should == { }
  end

  it "string with G/M/K at the end should not be converted" do 
    "aaaG".to_num.should == "aaaG"
    "aaaM".to_num.should == "aaaM"
    "aaaK".to_num.should == "aaaK"
  end

  it "should convert int" do
    "42".to_num.should == 42
  end

  it "should convert negative int" do
    "- 1233".to_num.should be_a_kind_of String
    "-1233".to_num.should be_a_kind_of Numeric
    "-   1233".to_num.should be_a_kind_of String
    "-1".to_num.should be -1
  end


  it "should honor plus with number" do
    "+42".to_num.should == 42
    "+ 42".to_num.should == "+ 42"
    "+0.1".to_num.should == 0.1
  end

  it "should return string for not number" do 
    "qwerwqerr".to_num.should == "qwerwqerr"
  end

  it "should convert  1K to 1024" do
    "1K".to_num.should == 1024
    "1 K".to_num.should == 1024
    "0.1 K".to_num.should == 102.4
  end

  it "should convert number 1M to number" do
    "1M".to_num.should == 1024*1024
    "1 M".to_num.should == 1024*1024
    "0.1 M".to_num.should == 0.1 * 1024*1024
  end

  it "should convert 1G to number" do
    "1G".to_num.should == 1024*1024*1024
    "1 G".to_num.should == 1024*1024*1024
    "0.1G".to_num.should == 0.1 * 1024*1024*1024
  end

end

