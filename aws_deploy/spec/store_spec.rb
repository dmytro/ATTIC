
require_relative 'spec_helper'

shared_examples_for "Marshal File" do

  it "path should be a string" do 
    klass.new.file.should be_a String
  end
  
  it "path should be a valid path" do 
    File.fnmatch("*#{path}", klass.new.file).should be true
  end

  it "path should be a full path" do 
    klass.new.file.should =~ /^\//
  end
  

  context "dump and forget" do

    before { @store = klass.new.store }

    it "dump should create file" do
      File.should exist @store.file
    end
    
    it "forget should delete the file" do 
      @store.forget
      File.should_not exist @store.file
    end
  end

end


describe AWSDeploy::Marshal do 

  let (:klass)         { AWSDeploy::Marshal }
  let (:absolute_path) { "/tmp/testfile"}
  let (:relative_path) { "tmp/testfile"}

  context :file do 
    context :absolute_path do
      let (:path) { absolute_path }
      before {  APP[:app][:marshal] = path }
      
      it_behaves_like "Marshal File"
    end
    
    
    context :relative_path do
      let (:path) {relative_path}
      before {  APP[:app][:marshal] = path }
      
      it_behaves_like "Marshal File"
      
      it "produce a full path" do 
        klass.new.file.should == File.join(APP[:root], path)
      end
    end
  end

  context :data do
    before { APP.delete :marshal }
    before { @store = klass.new }
    before { @data = @store.data }
    before {  @test = { :test => 'test'} }
    before {  @test2 = { :test2 => 'test2'} }

    context :new do 
      subject { @data }

      it "init should create :marshal hash" do 
        APP.should have_key :marshal
      end
      
      it { should be_a Hash }
      it { should == { } }
    end

    context :init_test_data do 
      before {  @store = klass.new(@test)}

      it "data should be a Hash" do 
        @store.data.should be_a Hash
      end


      context :read_stored_data do 

        subject { @read = ::Marshal.load(File.read @store.file) }

        it { should be_a Hash }
        it { should == @test }
      end
    end

    context :store_test_data do 
      before {  @store = klass.new  }
      before {  @store.store(@test) }
      subject { @read = ::Marshal.load(File.read @store.file) }

      it { should be_a Hash }
      it { should == @test }

    end

    context :merge_init_and_store_data do 
      before  do 
        @store = klass.new(@test)
        @store.store(@test2)
        @read = ::Marshal.load(File.read @store.file)
      end
      subject { @read }

      it { should be_a Hash }
      it { should == @test.merge(@test2) }

      it "should load correct data" do
        should == @store.load.data
      end
      
      context :forget do

        it :single_key do
          @store.forget(:test).data.should == @test2
        end

      end
    end

    context :deep_merging do 

      before { 
        @dm1 = {  :a => 1,     :b => { :c => 3, :d => 4}}
        @dm2 = {  :a => 'aaa', :b => { :c => 'merged', :d => 4}, :e => 25}
        @dm2_1 = {  :a => 'aaa', :b => { :c => 'merged'}, :e => 25}
        @dm3 = {  :a => 'bbb', :e => nil }

        AWSDeploy::Marshal.new.forget
        @store = AWSDeploy::Marshal
      }
      
      it "deep merge 1" do
        @store.new(@dm1).store(@dm2).data.should == {:a=>"aaa", :b=>{:c=>"merged", :d=>4}, :e=>25}
      end

      it 'deep merge 2' do
        @store.new(@dm1).store(@dm2_1).data.should == {:a=>"aaa", :b=>{:c=>"merged", :d => 4}, :e=>25}
      end

      it 'deep merge 3' do
        @store.new(@dm1).store(@dm3).data.should == {:a=>"bbb", :b=>{:c=>3, :d=>4}, :e=>nil}
      end
      
      it 'deep merge 4' do
        @store.new(@dm1).store(@dm2_1).store(@dm3).data.should == {:a=>"bbb", :b=>{:c=>"merged", :d => 4}, :e=>nil}
      end

      it 'deep merge 5' do
        @store.new(@dm1).store(@dm3).store(@dm2_1).data.should == {:a=>"aaa", :b=>{:c=>"merged", :d => 4}, :e=>25}
      end

    end


  end #:data

end  
