module AWSDeploy
  ##
  # Helper methods and higher level abstractions for AWS::Route53
  # class methods.
  #
  # @author Dmytro Kovalov, dmytro.kovalov@gmail.com
  #
  # == Usage
  # 
  #     AWSDeploy::Route53.new(APP[:ec2]).add \
  #       APP[:ec2][:domain], 
  #       APP[:ec2][:subdomain], 
  #       instance.ip_address

  class Route53 < ::AWS::Route53

    ##
    #
    # @param [Hash] props Configuration properties for EC2
    #
    # @option :secret  [Hash] :access_key_id and :secret_access_key pair
    #
    def initialize props=APP[:ec2]
      # Defaults
      props = { 
      }.merge props

      super props[:secret]

      # Initialize hash for DNS record creation in R53
      @record = {
        :hosted_zone_id => nil,
        :change_batch => { 
          :changes => [{ 
                         :action => nil,
                         :resource_record_set  => {
                           :name => nil,
                           :type => 'A',
                           :ttl => APP[:ec2][:dns][:ttl] || 300,
                           :resource_records => []
                         }
                       }]
        }
      }
      # 
      @actions = %w{DELETE CREATE}
    end

    attr_accessor :record
    ##
    # List all zone in Route 53.
    #
    # Helpermethod, calls client.list_hosted_zones.
    #
    # @return [Array] Array value of list_hosted_zones[:hosted_zones]
    
    def list_zones
      a = self.client.list_hosted_zones[:hosted_zones]
    end

    ##
    # Helper method to get zone by its properties hash
    #
    # Calls AWS::Route53.client.get_hosted_zone
    #
    # @param [Hash] hash Options hash
    # @return [AWS::Core::Response]
    # 
    def get_zone hash
      self.client.get_hosted_zone hash
    end

    ##
    # Find by zone name and return zone from list of hosted zones
    #
    # @param [String] name zone name
    #
    # @return [AWS::Core::Response] 
    #   Returns +nil+ if not found
    #   * +:hosted_zone+ (Hash)
    #     * +:id+ (String)
    #     * +:name+ (String)
    #     * +:caller_reference+ (String)
    #     * +:config+
    #     * +:resource_record_set_count+
    #   * +:delegation_set+
    #     * +:name_servers_ [Array]
    #
    def by_name name
      begin
        self.get_zone( :id => 
                       list_zones.find { |z| z[:name] == name }[:id]
                       )
      rescue NoMethodError
        puts '='*80 + "\n Failed to find hosted DNS zone by name: #{name}\n" +'='*80
        nil
      end
    end


    ##
    # Return id of a zone from it's name
    #
    # If zone does not exists, then !{by_name} metod returns `nil`,
    # rescue from thi by return `nil` too.
    #
    # @param [String] name
    # @return [String] Hosted zone ID
    #
    def id_by_name name
      begin
        by_name(name)[:hosted_zone][:id]
      rescue NoMethodError
        nil
      end
    end

    ##
    # Add subdomain to zone
    #
    # @see update_record
    #
    # @param [String] zone
    # @param [String] domain
    # @param [String] ip_address
    #
    def add zone, domain, ip_address
      update_record :create, zone, domain, ip_address
    end

    ##
    # Calls delete and add, if record does not exist exit form delete
    # is ignored.
    #
    # @see update_record
    #
    # @param [String] zone
    # @param [String] domain
    # @param [String] ip_address
    #
    def add_or_replace zone, domain, ip_address
      update_record :delete, zone, domain, ip_address
      update_record :create, zone, domain, ip_address
    end

    ##
    # Remove subdomain from zone
    #
    # @see update_record
    #
    # @param [String] zone
    # @param [String] domain
    # @param [String] ip_address
    #
    def del zone, domain, ip_address
      update_record :delete, zone, domain, ip_address
    end

    ##
    # Called from add or del
    #
    # @param [String, Symbol] action :delete or :create
    # @param [String] zone
    # @param [String] domain
    # @param [String] ip_address
    #
    def update_record action, zone, domain, ip_address
      return { :result => "Route53 step is diabled" } unless APP[:app][:steps][:route53]
      action    action
      domain    zone
      subdomain "#{domain}.#{zone}"
      ip        ip_address
      begin
        client.change_resource_record_sets record
      rescue Exception => e
        puts "\n\n\n*** DNS deployment failed !"
        puts "*** #{e.class}: #{e.message}"
        puts "*** see errors with ./deploy.rb --show #{APP[:cap][:branch]} \n\n"
        { 
          :change_info => e.message  + "/ Record:" + record.inspect 
        }
      end
    end

    # Sets the IP address for domain record
    def ip ip
      record[:change_batch][:changes].first[:resource_record_set][:resource_records] = [{ :value => ip}]
    end

    # Set action
    def action action
      action = action.to_s.upcase
      abort "Action must be one of #{@actions.inspect}" unless @actions.include? action
      record[:change_batch][:changes].first[:action] = action
    end

    # Set zone name where sub-domain to be created
    def domain zone=nil
      if zone
        record[:hosted_zone_id] = id_by_name zone
      end
      record[:hosted_zone_id]
    end

    # Set sub-domain to be created
    
    def subdomain subdomain
        record[:change_batch][:changes].first[:resource_record_set][:name] = subdomain
    end


  end
end
