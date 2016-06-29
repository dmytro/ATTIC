# Load defaults from configuration file
require_relative '../../config/environment'

require_relative 'cli/cli'


module AWSDeploy
  class CLI
    
    ##
    # Destroy AWS instance and remove Route53 domain pointing to it.
    #
    # @param [String] name instance name, i.e same as branch of
    #     the instance, key in local store file.
    def self.destroy name
      ec2 = AWSDeploy::EC2.new APP[:ec2]
      memory = AWSDeploy::Marshal.new

      stored = memory.data[name] || abort("Don't know about instance #{name} " )
      dns = stored[:config][:ec2][:dns]

      instance = ec2.instances[stored[:instance][:id]] || abort("Instance name #{name} does not exist")

      instance.stop
      instance.terminate if APP[:ec2][:terminate_on_stop]

      p "Disabling DNS #{dns[:domain]} #{dns[:subdomain]} #{stored[:instance][:ip_address]}"

      AWSDeploy::Route53.new.del dns[:domain], dns[:subdomain], stored[:instance][:ip_address]

      memory.forget name
      
      return true
    end




    ##
    # Deploys new EC2 instance and create Route53 DNS entry for it
    # with subdomain name as branch name.
    def self.deploy
      branch = APP[:cap][:branch]
      
      store = AWSDeploy::Marshal.new.forget(branch).store( branch => { 
                                                             :starting => Time.now,
                                                             :config => APP
                                                           })
      
      ec2 = AWSDeploy::EC2.new APP[:ec2]
      
      instance = ec2.start_instance
      store.store({ branch => 
                    { :instance => {
                        :id => instance.id,
                        :launch_time => instance.launch_time ,
                        :ip_address => instance.ip_address ,
                        :private_ip_address => instance.private_ip_address ,
                        
                      }
                    }
                  })
      
      puts (ec2.create? ? "New Instance " : "") + "Started. DNS name: " + instance.dns_name
      puts "Instance is " + instance.status.to_s
      store.store(branch => {
                    :instance => {
                      :id => instance.id,
                      :started => Time.now
                    }
                  })
      
      ec2.wait_for_ssh(instance); puts "SSH OK"
      
      store.store(branch => { :instance => {:ssh_ok => Time.now }})
      
      puts "Starting deployment..."
      store.store(branch => { :chef => { :starting => Time.now }})
      
      AWSDeploy::Chef.run(ec2, instance, APP[:chef])
      
      store.store(branch => { :chef => { :done => Time.now }})      
      store.store(branch => { :cap => { :start => Time.now }})

      AWSDeploy::Cap.run(ec2, instance, APP[:cap])
      store.store(branch => { :cap => { :done => Time.now }})
      
      store.store(branch => 
                  { :instance => { 
                      :dns => 
                      AWSDeploy::Route53.new.add_or_replace(
                                                            APP[:ec2][:dns][:domain],
                                                            APP[:ec2][:dns][:subdomain],
                                                            instance.ip_address
                                                            ).merge({ :done => Time.now }) } }
                  )
      
      store.store(branch => { :done => Time.now })
    end

  end
end

