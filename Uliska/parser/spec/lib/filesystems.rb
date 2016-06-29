shared_examples_for "any filesystem" do

  context "any UNIX filesystem" do

    data = fss = root_fs = nil

    before(:each) do

      Uliska::Parser.instance.read("#{DATA_ROOT}/#{$data_file}")
      Uliska::Parser.load_parsers
      data = OpenStruct.new Uliska::Parser.data
      fss = data[:filesystems]
    end

    it "data[:filesystems] should be Array of Hashes" do
      fss.should be_a_kind_of(Array)
      fss.should_not be_empty
      fss.first.should be_a_kind_of(Hash)
    end
    
    it "should have root filesystem" do
      
      root_fs = fss.find { |x| x[:mounted_on]  == "/" }
      root_fs.should_not be_empty
      root_fs.should be_a_kind_of(Hash)
      root_fs.first.should be_a_kind_of(Array)

    end

    it "root FS should have required fields" do

      %w{ filesystem blocks used available use mounted_on
       mount_options inodes iused ifree iused fs_type }.each do |field|

        root_fs.should have_key(field.to_sym)
      end
    end

    it "numeric fields should be numeric" do
      %w{ blocks used available inodes iused ifree }.each do |field|
        root_fs[field.to_sym].should be_a_kind_of Numeric
      end
    end
    
    it "percent fields should have <number>% format" do
      %w{ use iuse }.each do |field|
        root_fs[field.to_sym].should match /^\d+%$/
      end
    end

    it "filesystem type, mount point should be a String" do
      %w{ fs_type filesystem mounted_on}.each do |field|
        root_fs[field.to_sym].should be_an_instance_of String
      end
    end
    
    it "mount_options should be Array" do
      %w{ fs_type filesystem mounted_on}.each do |field|
        root_fs[:mount_options].should be_an_instance_of Array
      end
    end

  end
end
