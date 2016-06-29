require "#{File.dirname(__FILE__)}/common"

describe "Uliska data" do
  before { $data_file = "deb.yml" }
  it_should_behave_like "Uliska data structure"

end
