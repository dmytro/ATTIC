$: << File.dirname(File.dirname(__FILE__)) + "/lib"
require "uliska_parser/extensions"

describe Array do

  array = [1,2,3,4,5,6]

  # Array of hashes
  array_ofh1 = [
                { :c1 => 10, 'c2' => 3, :bbb => 'asdfadsf'},
                { :c1 => 20, 'c2' => 4, :bbb => 'asdffa'},
                { :c1 => 30, 'c2' => 5, :bbb => 'asdfasfd'},
                { :c1 => 40, 'c2' => 6, :bbb => 'asdfasdf'},
               ]


  it "should calculate sum" do
    array.sum.should == 21
  end

  it "should calculate sum by column" do
    array_ofh1.sum_by(:c1).should == 100
    array_ofh1.sum_by('c2').should == 18
  end

end

a1 = [
      { :fs => "/home", :size => 20, :use => "20%"},
      { :fs => "/var", :size => 60, :use => "40%"},
      { :fs => "/usr", :size => 300, :use => "33%"},
      { :fs => "/tmp", :size => 10, :use => "90%"},
      'a',
     ]

a2 = [ 
      { :fs => "/var"},
      { :fs => "/home", :fstype => "ufs", :size => 40},
      { :fs => "/usr"},
      { :fs => "/export"},
      'b'
     ]

describe Array do 
  it "should merge" do
    a1.merge_by(a2, :fs)[0].should === 
      { :fs => "/home", :size => 40, :use => "20%", :fstype => "ufs" }
  end

end
