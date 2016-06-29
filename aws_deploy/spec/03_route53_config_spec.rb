

require 'spec_helper'


describe 'Route53' do 
  let (:ec2)  {  YAML.load_file(File.join($root, 'config/environment.yml'))[:ec2]}


  let (:dns) { ec2[:dns] }
  subject { dns }
  
  it { should have_key :domain }
  it "Hosted Domain name should end with a dot (.)"do 
    dns[:domain][-1].should == '.'
  end
  it { should have_key :subdomain }
  it "TTL should be number" do 
    subject[:ttl].should be_a_kind_of Fixnum
  end

end # 'EC2
