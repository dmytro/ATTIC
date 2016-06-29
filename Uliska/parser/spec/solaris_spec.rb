require "#{File.dirname(__FILE__)}/common"

describe "Solaris" do
  before { $data_file = "sol.yml" }
  it_should_behave_like "Uliska data structure"
  it_should_behave_like "any unix"
  it_should_behave_like "any filesystem"
end
