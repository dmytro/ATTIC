shared_examples_for "any linux v.2" do

  require 'ostruct'

  context "any Linux v.2" do

    data = nil

    before(:each) do

      Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
      Uliska::Parser.load_parsers
      data = OpenStruct.new Uliska::Parser.data
      
    end


    it "should have modules" do 
      data.kernel_modules.should be_a_kind_of Array
    end

    it "modules should have proper data" do
      data.kernel_modules.each do |row|
        row.should have_key :name
        row.should have_key :size
        row.should have_key :used_by_number
        row.should have_key :used_by
      end
    end

    it "modules should have proper data format" do
      data.kernel_modules.each do |row|
        row[:name].should be_a_kind_of String
        row[:size].should be_a_kind_of Fixnum
        row[:used_by_number].should be_a_kind_of Fixnum
        row[:used_by].should be_a_kind_of Array 
      end
    end

  end
end
