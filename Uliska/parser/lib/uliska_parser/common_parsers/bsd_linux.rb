# Parsers for command that produce similar output in BSD and Linux
module Uliska
  class Parser
    
    # Parse output of mount command and merge it with filesystems
    # information.
    # @return Parsed array of hashes 
    #    {:filesystem => String, :fs_type => String , :mount_options => Array}
    #
    def self.mount_parser
      out = []
      #   '/dev/sda1 on / type ext3 (rw,errors=remount-ro)'
      # FreeBSD (Darwin including) does not have 'type' part
      raw.mount.each do |line|

        if line.strip =~ /^([^ ]+) on [^ ]+( type ([^ ]+))? \((.*)\)$/
          fs_type = $3
          out.push( { :filesystem => $1,
                      :mount_options => $4.split(/,\s*/),
                    }.merge(fs_type ? { :fs_type => fs_type } : { })
                    )
        end
      end
      out
    end
    
  end
end
