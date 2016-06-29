#
# Parsers for `generic' UNIX commands, required in uliska_parser.rb
#
module Uliska
  class Parser

    require 'ostruct'
    # Parse uptime command output.
    #
    # @return [String] @data['uptime']
    # @return [Fixnum] @data['users'] Number of logged in users
    # @return [Array] @data['load_average'] 3 element Array of load averages 
    #      def parse_uptime
    #inst  = Uliska::Parser.instance
    parse :uptime do 

      if raw.uptime.strip =~ /^.*\s+up\s+(.*)\s*(\d+)\susers?,\s*load averages?:(.*)$/
        uptime, data[:users], data[:load_average] = $1, $2.to_i, $3.strip.split(/\s*[, ]\s*/).map(&:to_f)
      end
      uptime.gsub(/[ ,]*$/,'')
    end

    # @return [String] @data['hostname'] Hostname (AKA nodename)
    #     as returned by uname -n
    parse :hostname do
      raw.nodename
    end

    # Parse /etc/passwd file
    parse :local_users do
      colon_separated '/etc/passwd', %w{name password uid gid gecos homedir shell}
    end

    # Parse /etc/group file
    parse :local_groups do
      groups = colon_separated '/etc/group', %w{group password gid members}
      groups.each { |val| val[:members] = val[:members] ? val[:members].split(/\s*,\s*/) :[]}
    end
    
    # Result of env command
    parse :user_environment do
      colon_separated :env, %w{variable value}, "="
    end

    # Major kernel version 
    parse :kernel do
      raw.kernel.inject({ }) { |memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    # Just dmesg without any parsing
    parse :dmesg

    # Define kernel and hostname methods
    class << self
      def kernel
        OpenStruct.new data[:kernel]
      end

      def hostname
        data[:hostname]
      end
    end
    
    # Parse sysctl -a output, only for systems that have it, it
    # raw[:sysctl] is missing silently ignore it.
    parse :sysctl do
      break unless raw[:sysctl]

      raw[:sysctl].inject({ }) { |res,line| 
        key,val = line.split(/\s*[=:]\s*/,2) # FreeBSD/Darwin use ':' as separator, Linux/OpenBSD '='
        if key && val
          case res[key.strip]
          when Array
            res[key.strip] << val.strip.to_num
          when String, Fixnum
            # Darwin has multiple entries with the same key,value
            # Linux has multiple entries with the same key, different values. 
            res[key.strip] = [res[key.strip]] << val.strip.to_num unless val.strip.to_num == res[key.strip]
          else
            res[key.strip] = val.strip.to_num 
          end
        end
         
        res
      }
    end

    class << self
      # Helper method to gt to sysctl information easier
      def sysctl
        OpenStruct.new data[:sysctl]
      end
    end


    # Chain load additional files
    load_parsers kernel.name
    load_parsers [kernel.name, kernel.major]
    load_parsers [kernel.name, kernel.major, kernel.minor]

  end
end
