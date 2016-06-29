
require 'spec_helper'


describe 'EC2' do 

  before {  require_relative '../config/environment.rb' }
  let (:ec2)  {  APP[:ec2] }

  context :instance do
    let (:instance) { ec2[:instance] }
    subject { instance }

    %w{name create terminate_on_stop key_name user}.each do |key|
      it { should have_key key.to_sym }
    end

    context :pem do 
      subject { File.join($root, 'config', "#{ec2[:instance][:key_name]}.pem") }

      it { File.should exist(subject) }
      it { File.should be_readable(subject) }
      it { File.should_not be_world_readable(subject) }
      it { File.should_not be_world_writable(subject) }
    end # :pem

    context :create do
      it "should have ami_id or id" do 
        if instance[:create]
          ec2.should have_key :ami_id
        else
          instance.should have_key :id
        end  
      end 

    end # :create
  end # :instance

end # 'EC2
