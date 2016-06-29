module AWSDeploy
  class EC2 < ::AWS::EC2
    require 'net/ssh'

    require 'debugger'

    # Security group should exist and should be specified by :security_groups option
    #
    # @param [Hash] props Configuration properties for EC2
    #
    # @option :secret  [Hash] :access_key_id and :secret_access_key pair
    # @option :ami_id [String] AMI image id 
    # @option :security_group [String] security group name (not id).
    #
    def initialize props={ }
      # Defaults
      props = { 
        :security_group => 'default',
        :instance_type => 't1.micro'
      }.merge props
      
      # Configuration check
      [ :ami_id, :secret, :instance ].each do |x|
        abort "Configuration parameter :#{x} should exist" unless props.has_key? x
      end
      abort "Instance should have name" unless props[:instance].has_key? :name

      super props[:secret]
      @props = props
      @image = self.images[props[:ami_id]]
      @sec_group = self.security_groups.find props[:security_group]

    end # new

    attr_accessor :image

    # Security group object 
    # @see AWS::EC2::SecurityGroup
    attr_accessor :sec_group
    
    # Configuration properties for AWS EC2
    attr_accessor :props

    #
    # Create new AWS::EC2 instance
    #
    # @return [AWS::EC2::Instance] 
    def create

      return unless APP[:app][:steps][:ec2]

      instance = image.run_instance( 
                                    :key_name => props[:instance][:key_name],
                                    :security_groups => sec_group,
                                    :instance_type => props[:instance_type],
                                    )
      instance
    end
    
    ##
    # Return configuration parameter - create new instance or reuse
    # existing.
    #
    def create?
      props[:instance][:create] == true
    end

    ##
    # See if we configured to create new instances each time or
    # reusing instances.
    #
    # If create is false or :try_reuse, return true. Otherwise false.
    #
    def reuse?
      props[:instance][:create] == false || props[:instance][:create] == :try_reuse
    end

    ##
    # If we are trying to reuse instance, find exisiting instance
    # either by configured [:instance][:id], or find ID from EC2 by
    # its name.
    def find_id
      return nil unless self.reuse?
      return self.props[:instance][:id] if self.props[:instance].has_key? :id
      self.class.list.find {  |x| x[:name] == self.props[:instance][:name] }
    end

    ##
    # start_instance is a helper method that will call create if
    # required or simply start exising instance.
    #
    def start_instance

      return unless APP[:app][:steps][:ec2]

      instance = case
                 when self.create? 
                   self.create
                 when self.reuse?
                   list = self.find_id
                   if list 
                     self.instances[list[:id]] 
                   else 
                     self.create
                   end
                 when props[:instance][:id]
                   self.instances[props[:instance][:id]]
                 else
                   abort "Asking to re-use exising instance, but instance ID is not provided in the configuration"
                 end
      
      abort "Instance ID not known" if instance.nil?
      sleep 1 until instance.status != :pending

      instance.add_tag('Name', :value => props[:instance][:name])

      instance.start unless instance.running?
      sleep 1 until instance.running?
      instance
    end

    ##
    # Start existing instance    
    #
    # @param [String] amiid  ID of the instance to start
    #
    def self.start amiid
      report "Starting instance #{amiid}..."
      i = self.new(APP[:ec2]).instances[amiid]
      i.start
      sleep 1 until i.status == :running
      report "OK"
    end


    ##
    # Stop running instance.
    #
    # @param [String] amiid  IF of the instance to stop
    #
    def self.shutdown amiid
      report "Stopping instance #{amiid}..."
      i = self.new(APP[:ec2]).instances[amiid]
      i.stop
      sleep 1 until i.status == :stopped
      report "OK"
    end



    ##
    # Terminate  instance.
    #
    # @param [String] amiid  IF of the instance 
    #
    def self.terminate amiid
      report "Terminating instance #{amiid}..."
      i = self.new(APP[:ec2]).instances[amiid]
      i.terminate
      sleep 1 until i.status == :terminated
      report "OK"
    end

    ##
    # List remote instances in AWS
    #
    def self.list
      self.new(APP[:ec2]).instances.map do |i|
        {
          id:        i.id,
          name:      i.tags.to_h['Name'],
          ip:        i.ip_address,
          status:    i.status,
          launched:  i.launch_time.strftime("%y-%m-%d %H:%M"),
          type:      i.instance_type,
          os:        i.platform,
          image:     i.image.exists? ? i.image.name : 'n/a'
        }
      end
    end

    # Sleep in loop waiting until SSH is available
    #
    def wait_for_ssh instance

      return unless APP[:app][:steps][:ec2]

      key_data = File.read "#{APP[:config]}/#{props[:instance][:key_name]}.pem"

      begin
        puts "Waiting for SSH to be available"
        STDOUT.flush
        Net::SSH.start(instance.ip_address, "ubuntu",
                       :key_data => key_data,
                       :timeout => 10
                       ) do |ssh|
          puts "Running 'uname -a' on the instance yields:"
          puts ssh.exec!("uname -a")
        end
      rescue Errno::EHOSTUNREACH
        abort "  Host unreachable"
#       rescue Errno::ECONNREFUSED
#         abort "  Connection refused"
      rescue Net::SSH::AuthenticationFailed
        abort "  Authentication failure"
      rescue SystemCallError, Timeout::Error => e  
        # port 22 might not be available immediately after the instance finishes launching
        print '.'
        sleep 1
        retry
      end
    end


  end

end


