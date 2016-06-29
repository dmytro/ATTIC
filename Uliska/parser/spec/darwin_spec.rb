require "#{File.dirname(__FILE__)}/common"

describe "Darwin" do
  before { $data_file = "darwin.yml" }
  it_should_behave_like "Uliska data structure"
  it_should_behave_like "any unix"
  it_should_behave_like "unix with sysctl"
  it_should_behave_like "any filesystem"
end
