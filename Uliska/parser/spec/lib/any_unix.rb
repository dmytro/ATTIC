shared_examples_for "any unix" do

  require 'ostruct'
  require 'pp'

  data = nil
  
  before(:each) do
    
    Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
    Uliska::Parser.load_parsers
    data = OpenStruct.new Uliska::Parser.data
    
  end

  context "any UNIX" do

    #
    # hostname
    #
    it "should have hostname" do 
      data.hostname.should_not be_empty
    end

    it "hostname should be a String" do 
      data.hostname.should be_a_kind_of String
    end

    #
    # uptime
    #
    
    it "uptime should have load averages" do
      data.load_average.should_not be_empty
    end

    it "load avarages should be 3 element array of Floats" do
      data.load_average.should be_a_kind_of Array
      data.load_average.count.should be 3
      data.load_average.each do |num|
        num.should be_a_kind_of Numeric
      end
    end

    #
    # Users
    #

    it "Logged in users should be a number" do # TODO
      data.users.should be_a_kind_of Numeric
    end

    it "should have dmesg" do 
      data.dmesg.should_not be_empty
      data.dmesg.should be_a_kind_of Array
      data.dmesg.first.should be_a_kind_of String
    end
    #
    # /etc/group
    #
    it "should have /etc/group" do # TODO
      data.local_groups.should_not be_empty
      data.local_groups.should be_a_kind_of Array
    end

    it "group ID should be numeric" do 
      data.local_groups.first[:gid].should be_a_kind_of Fixnum
    end

    #
    #
    # /etc/passwd
    #
    it "should have /etc/passwd" do
      data.local_users.should_not be_empty
      data.local_users.should be_a_kind_of Array
    end

    it "user ID in /etc/passwd should be nuneric" do 
      data.local_users.each do |user|
        user[:uid].should be_a_kind_of Fixnum
      end
    end

    it "root UID in /etc/passwd should be O" do 
      data.local_users.find { |x| x[:name] == 'root'}[:uid].should be 0
    end

    it "should have root user" do
      data.local_users.find { |x| x[:name] == 'root'}.should_not be_empty
    end


    # 
    # Environment
    # 
    it "user environment should not be empty" do
      data.user_environment.should be_a_kind_of Array
    end

    it "user environment should have variable and value keys" do
      data.user_environment.each do |entry|
        entry.should be_a_kind_of Hash
        entry.should have_key :variable
        entry.should have_key :value
      end
    end


    #
    # Kernel
    # 
    it "kernel should have minor and major versions" do
      kern = Uliska::Parser.kernel
      kern.name.should be_a_kind_of String
      kern.major.should be_a_kind_of Fixnum
      kern.minor.should be_a_kind_of Fixnum
    end

  end

  context "memory and swap" do

    memory = swap = vmstat = nil

    before do
      swap = OpenStruct.new data.swap
      memory = OpenStruct.new data.memory
      vmstat = OpenStruct.new data.vmstat
    end

    it "should have physical memory" do
      memory.should_not be_empty
    end
    
    it "should have swap" do
      swap.should_not be_empty
    end

    context "vmstat" do
      
      it "should be Hash" do
        data.vmstat.should be_a_kind_of Hash
      end

      it "values should be Numeric" do
        data.vmstat.each do |k,v|
          k.should be_a_kind_of String
          v.should be_a_kind_of Integer
        end
      end

    end

    context "memory" do

      it "should be numeric" do
        memory[:total].should be_a_kind_of Integer
      end

      it "total should > 0" do
        memory[:total].should > 0
      end

      it "should have free memory" do
        memory[:free].should be_a_kind_of Integer
      end

      it "free memory should be >= 0 " do
        memory[:free].should >= 0        
      end

    end # physical memory
    context "swap" do

    it "should have fields :total, :free, :segments" do
      data.swap.should be_a_kind_of Hash
      data.swap.should have_key :total
      data.swap.should have_key :free
      data.swap.should have_key :segments
    end

      it "should be numeric" do
        swap.total.should be_a_kind_of Fixnum
      end

      it "swap should be >= 0 " do
        swap.total.should >= 0
      end

      it "free swap should be nuumeric" do
        swap.free.should be_a_kind_of Fixnum
      end

      it "free swap should be >= 0 " do
        swap.free.should >= 0
      end
      
      context "swap segments" do
        
        it "should be an Array" do
          data.swap[:segments].should be_a_kind_of Array
        end

        it "every segment should be a Hash with keys :device, :size, :used" do 
          data.swap[:segments].each do |seg|
            seg.should be_a_kind_of Hash
            seg.should have_key :device
            seg.should have_key :size
            seg.should have_key :used
          end
        end


      end

    end # swap
  end

end
