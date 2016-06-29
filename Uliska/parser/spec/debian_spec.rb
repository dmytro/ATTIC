require "#{File.dirname(__FILE__)}/common"

describe "Debian Linux" do
  before { $data_file = "deb.yml" }
  it_should_behave_like "Uliska data structure"
  it_should_behave_like "any linux"
  it_should_behave_like "any linux v.2"

end
