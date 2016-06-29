
require 'spec_helper'


describe 'Configuration' do 

  let (:yaml) {  File.join($root, 'config/environment.yml') }

  context 'environment.yml' do 
    subject { yaml }

    it { File.should exist(subject)}
    it "should be parseable " do  
      lambda { YAML.load_file subject }.should_not raise_error
    end

    context 'parsed hash' do 
      let (:hash) { YAML.load_file yaml }
      subject { hash }
      
      it {  should have_key :app }
      it {  should have_key :ec2 }
      it {  should have_key :chef }
      it {  should have_key :cap }
    end

    context "components" do
      before {  require_relative '../config/environment.rb' }
      let (:hash) { APP }
      
      context :ec2 do 
        subject {  hash[:ec2] }

        %w{instance_type  ami_id security_group root-device-type instance dns}.each do |key|
          it { should have_key key.to_sym }
        end

        it { File.should exist(hash[:app][:secret]) }

      end # :ec2

      context :chef do
        subject { hash[:chef]}
        let (:dir) { File.join($root, hash[:chef][:dir]) } 

        it { should have_key :json }
        it { should have_key :librarian_install }

        it { Dir.should exist(dir) }
        it { File.should exist File.join(dir, subject[:json])}
        it { File.should exist File.join(dir, "deploy.sh")}

      end # chef

      context :cap do
        subject { hash[:cap]}
        let (:dir) { File.join($root, hash[:cap][:directory]) } 

        %w{ directory branch generate_config stage task}.each do |key|
          it { should have_key key.to_sym}
        end
        
        it { File.should exist(File.join(dir, "config", "deploy.rb")) }
        
        it { Dir.should exist(dir)}

        context "multistage extension" do 
          it { Dir.should exist(File.join(dir, "config", "deploy")) }

          it { File.should exist(File.join($root, 'config', 'staging.rb.erb')) }
          # it { File.should exist(File.join($root, 'config', 'secret.yml')) }
        end
      end
    end

  end
end
