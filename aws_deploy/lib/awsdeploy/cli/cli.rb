require 'mixlib/cli'

##
#
# Process command line options.
#
# Command line options have priority over configured
# properties. Applicaiton first loads a configuration file, then it
# overwrites it from CLI arguments by user.
#
# Other command line options are loaded from files in ./lib/awsdeploy/cli/*.rb
#
module AWSDeploy
  class CLI
    include Mixlib::CLI


    option :no_test, :description => "Do not run rspec configuration tests at start",
    :long => '--no-test'
    

    #
    # Process command line arguments
    #
    option :dump, :description => "Dump configuration and exit",
    :short => '-d', :long => '--dump',
    :on => :head,
    :exit => 0,
    :proc => Proc.new { pp APP }
    
    option :man, :description => 'See longer help',
    :long => '--man',
    :on => :tail,
    :exit => 0,
    :show_options => true,
    :proc => Proc.new { 
    print <<EOF

This script deploys and destroys AWS instances. Information about
deployed instance is stored locally and can be operated by clmmand
line switches.

Action is specified by one of the action switches: deploy, destroy,
list, show, forget.

* Deploy and destroy actions create or accordingly delete previously
  deployed instance. Destroy switch requires an instance name. While
  deploy reads instance name from configuration file.

List, reset, forget actions operate local memory.

* List   - shows names of all instances stored locally.
* Reset  - removes single instance from local memory (not affecting
           instance deployed to AWS).
* Forget - removes and resets all local memory (without touching instances).

Other options override defaults set in configuration file. 

EOF

}
    
    option :help, :description => "Show this message",
    :short => "-h",
    :long => "--help",    
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0


    option :config, :description => "Path to local configuragtion file",
    :short => "-c CONFIG", :long => "--config CONFIG",
    :proc => Proc.new {  |x| 
      abort "Configuration file not found : #{x}" unless File.exist?(File.expand_path x)
      APP[:app][:config] = x
      APP.deep_merge! YAML.load_file x  
    }

    option :quiet, :description => "Do not print to STDOUT",
    :shrt => "-q", :long => "--quiet",
    :proc => Proc.new { $quiet = true }

  end
end


def report str
  return if $quiet
  puts "#{Time.now.strftime("%H:%M:%S").chomp} #{str}"
end
# Command line options specific for sub-components

require_relative 'aws'
require_relative 'store'
require_relative 'chef'
require_relative 'cap'

