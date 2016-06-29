require "#{File.dirname(__FILE__)}/common"

describe "OpenBSD" do
  before { $data_file = "obsd.yml" }
  it_should_behave_like "Uliska data structure"
  it_should_behave_like "any unix"
  it_should_behave_like "any filesystem"
end
