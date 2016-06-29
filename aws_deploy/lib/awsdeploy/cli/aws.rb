module AWSDeploy
  class CLI
    include Mixlib::CLI

    #
    # EC2 
    # --------------------
    option :region, :description => "AWS EC2 region (NOT IMPLEMENTED)",
    :long => '--ec2-region REG'

    option :ami, :description => "EC2 ami-id for new instances",
    :long => '--ec2-ami AMIID', 
    :proc => lambda { |x| APP[:ec2][:ami_id] = x }

    #
    # EC2 - remote operations
    # ----------------------
    option :list_remote, :description => 'List remote instances in AWS (options: long)',
    :long => '--list-remote [LONG]',
    :exit => 0,
    :proc => lambda { |param| 
      if param == 'long'
        format =       "%-10.10s  %-25.25s  %-15.15s  %-8.8s %-14s %-10s %-7s %s\n"
        printf format, "Id",      "Name",   "IP",     "Status", "Launched", 'Type', 'OS', 'Image'
        width = 160
      else
        format = "%-10.10s  %-25.25s  %-15.15s  %-8.8s %-14s\n"
        printf format, "Id", "Name", "IP", "Status", "Launched"
        width = 90
      end

        puts  '-' * width

      ::AWSDeploy::EC2.list.each do |row|
        printf format, row[:id], row[:name], row[:ip], row[:status], row[:launched], row[:type], row[:os], row[:image]
      end
      puts '-' * width
    }

    option :destroy_remote, 
    :description => "DANGEROUS!!! Shutdown and terminate instance in EC2.",
    :long => '--terminate-remote AMI-ID',
    :exit => 0,
    :proc => Proc.new {  |i| 
      ans = ask "Do you really want to destroy instance #{i} ? (yes/no)"
      abort "OK, try next time " unless ans == 'yes'
      ::AWSDeploy::EC2.terminate i 
    }
    


    option :shutdown_remote, 
    :description => "Shutdown instance in EC2.",
    :long => '--stop-remote AMI-ID',
    :exit => 0,
    :proc => Proc.new {  |i| ::AWSDeploy::EC2.shutdown i }


    option :start_remote, 
    :description => "Start exising instance in EC2.",
    :long => '--start-remote AMI-ID',
    :exit => 0,
    :proc => Proc.new {  |i| ::AWSDeploy::EC2.start i  }
    #
    # Route 53 DNS
    # ----------------------------------------
    option :domain, :description => "DNS domain name for new application server. If not provided use branch name",
    :short => "-d NAME",
    :long  => '--dns NAME',
    :proc => Proc.new { |x| APP[:ec2][:dns][:subdomain] = x }


    option :deploy, 
    :description => "Deploy new instance: create, run chef, capistrano and create DNS dubdomain",
    :long => '--deploy',
    :on => :head

    option :destroy, 
    :description => "Destroy configured and deployed instance: delete it and drop DNS dubdomain",
    :long => '--destroy BRANCH',
    :on => :head


  end
end
