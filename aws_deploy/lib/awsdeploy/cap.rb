module AWSDeploy
  class Cap < Shell
    require 'systemu'
    require 'erb'
    
    def self.run(*p)  
      self.new(*p).init.run 
    end

    #
    # @param [AWSDeploy::EC2.instance] instance
    # @param [Hash] cap Capistrano configuration from ./config/environment.yml
    def initialize ec2, instance, cap={ }
      pp ec2
      @instance = instance
      @cap = { 
        :task => 'deploy',
        :branch => 'master'
      }.merge(cap)

      @source  = "#{APP[:config]}/#{cap[:stage]}.rb.erb"
      @target  = "#{cap[:directory]}/config/deploy/#{cap[:stage]}.rb"
      @ssh_key = "#{APP[:config]}/#{ec2.props[:instance][:key_name]}.pem"
      @branch  = "#{cap[:branch]}"
    end

    attr_accessor :instance, :cap

    # Parse all ERB templates and prepare for deployment
    def init

      if cap[:generate_config].include? cap[:stage]
        File.open(@target, 'w') do |f|
          f.print ERB.new(File.read @source).result(binding)
        end
      end
      self
    end

    # Run capistrano deployment
    def run
      return unless APP[:app][:steps][:capistrano]

      pp "(cd #{cap[:directory]} && cap #{cap[:stage]} #{cap[:task]} )"
      super "(cd #{cap[:directory]} && bundle install )"
      super "(cd #{cap[:directory]} && bundle exec cap #{cap[:stage]} #{cap[:task]} )"
    end

  end
end
