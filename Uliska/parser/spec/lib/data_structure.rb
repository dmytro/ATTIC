require 'ostruct'
require 'pp'

# RSpec file for data structure of the parser output. For the
# descritpion of requirements see ParserDataStructure.md



# TODO: Hash keys: :name or singular of parent

# TODO: Array values: Hash, Numeric, String

shared_examples_for "Uliska data structure" do

  before(:each) do
    Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
    Uliska::Parser.load_parsers
    @data = Uliska::Parser.data
    # @data = {  1 => File.open("a", "w")}
  end

  subject { @data }

  context "Uliska data" do
    
    it { should be_a Hash }

    it { should have_keys_in_class [String, Symbol] }
    it { should have_values_in_class [Fixnum, String, Numeric, Hash, Array] }
    it { should have_array_values_in_class [String,Numeric,Hash] }
    it { should have_array_values_of_the_same_class }

  end
end
