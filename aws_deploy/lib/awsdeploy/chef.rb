module AWSDeploy
  class Chef < Shell
    require 'systemu'

    def self.run *p
      self.new(*p).run
    end

    # 
    # 
    # @param [AWSDeploy::EC2] ec2 instance of EC2 connection objects
    # @param [AWSDeploy::EC2.instance] instance Create and/or started instance of EC2 host
    # @param [Hash] chef Chef configuration
    #
    def initialize ec2, instance, chef={ }
      @instance = instance
      @ec2 = ec2
      @chef = { 
        :dir => './lib/chef-solo',
        :json => 'webserver.json'
      }.merge chef
      init
    end

    attr_reader :instance, :ec2, :chef
    
    # Create cookbooks directory and pull in cookbooks
    def init
      unless chef[:librarian_install] == false
        status, stdout, stderr = 
          systemu "(cd #{chef[:dir]} && mkdir -p cookbooks && librarian-chef install)"
        abort "ERR: #{stderr}" unless status.success?
      end
      self
    end
    
    # Run chef-solo deployment
    def run
      return unless APP[:app][:steps][:chef]
      
      super "ssh-agent /bin/bash -x -c '( ssh-add ./config/#{ec2.props[:instance][:key_name]}.pem && ssh-add -L 2>&1 && cd #{chef[:dir]} && ./deploy.sh #{ec2.props[:instance][:user]}@#{instance.dns_name} #{chef[:json]} ) 1>&2'"
    end

  end
end
