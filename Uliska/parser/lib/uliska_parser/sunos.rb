module Uliska
  class Parser

    # Solaris mount command output:
    # / on rpool/ROOT/s10_8-11 read/write/setuid/devices/rstchown/dev=2d50002 on Thu Jan  1 09:00:00 1970
    # /devices on /devices read/write/setuid/devices/rstchown/dev=4a00000 on Fri Feb 10 16:49:28 2012
    def self.mount_parser
      out = []
      raw.mount.each do |line|
        if line.strip =~ /^([^ ]+) on ([^ ]+) ([^*]+) on (.*)$/
          out.push({
                    :mounted_on => $1,
                     :filesystem => $2,
                     :mount_options => $3.split('/'),
                     :mount_time => $4
                   })
        end
      end
      out
    end

    def self.inodes_parser
      space_separated raw.inodes[-1..-1], %w{ filesystem iused ifree iuse mounted_on}
    end

    # @method :vmstat Parse result of vmstat -s into Hash. Parse
    # memory uses result of this, so it should go before +parse :memory+.
    parse :vmstat do 
      value_label_pairs :vmstat
    end

    parse :memory do 
      size = raw.prtconf.find { |x| x =~ /^Memory size:/}.split(':')[1]
      number,units = size.split
      
      { 
        :total => number.to_i * case 
                                when units =~ /Mega/ then 1024*1024
                                when units =~ /Gig/ then 1024*1024*124
                                else 1
                                end,
        
        :free  => nil,
        :segments => [
                     ]
      }
    end

    # Parse output of swap -l
    # @return [Hash] like
    #   :swap=>
    #   {:total=>1613808,
    #    :free=>1613808,
    #    :segments=>
    #     [{:swapfile=>"/dev/zvol/dsk/rpool/swap",
    #       :dev=>"181,1",
    #       :swaplo=>"8",
    #       :blocks=>"1572856",
    #       :free=>"1572856",
    #       :type=>:partition},
    parse :swap do
      fields = space_separated raw.swap[1..-1], %w{swapfile device swaplo size free}
      fields.map { |x| 
        x[:type] = x[:dev] == '-' ? :file : :partition; 
        x[:used] = x[:size] - x[:free]; 
        x
      }

      { 
        :total => fields.sum_by(:blocks).to_i / 2,
        :free => fields.sum_by(:free).to_i / 2,
        :segments => fields
      }
    end

    # Parse ouput of `df-k', `df -F ufs -o i', mount for Solaris.
    parse :filesystems do
      fss = df_parser # From common parsers Linux_Solaris
      fss.merge_by(mount_parser, :filesystem)

      fss.merge_by(inodes_parser, :filesystem)
      fss.map { |x| x[:iused] ||= 0; x[:ifree] ||= 0;  x[:iuse] ||= '0%'; x[:inodes] = x[:iused] + x[:ifree] }

      fss.merge_by( colon_separated(raw.fs_types, %w{ mounted_on fs_type}, /\s*:\s*/), :mounted_on)
      fss
    end



  end
end
