module Uliska
  class Parser

    require 'uliska_parser/common_parsers/bsd_linux'
    require 'uliska_parser/common_parsers/linux_solaris'
    
    require 'uliska_parser/network/linux'
    
    parse :distro
    def self.distro; data[:distro] end

    # @method :vmstat Parse result of vmstat -s into Hash. 
    parse :vmstat do 
      value_label_pairs :vmstat
    end

    # @method memory
    # Parse output of free command. 
    parse :memory do
      out = space_separated(
                            [raw.memory.find{ |x| x =~ /^Mem:/}],
                            %w{mem total used free shared buffers cached}
                            ).first
      out.shift
      out
    end

    # Parse output of swapon -s
    parse :swap do
      fields = space_separated raw.swap[1..-1], %w{device type size used priority}

      { 
        :total => (total = fields.sum_by(:size).to_i),
        :free  => (total - fields.sum_by(:used).to_i),
        :segments => fields
      }
    end

    # Parse output of `df -k', `mount' and `df -i'.
    # @return  [Hash] 
    #     :filesystems=> [{:filesystem=>"/dev/sda1", :blocks=>"7867856",
    #                       :used=>"1104664", :available=>"6363528", :use=>"15%",
    #                       :mounted_on=>"/", :fs_type=>"ext3", 
    #                       :mount_options=>["rw",
    #                                        "errors=remount-ro"], 
    #                       :inodes=>"499712", :iused=>"47461",
    #                       :ifree=>"452251", :iuse=>"10%", :mounted=>"/"},
    parse :filesystems do
      filesystems = df_parser
      
      filesystems.merge_by( mount_parser, :filesystem
                            ).merge_by( 
                                       space_separated(
                                                       raw.inodes, 
                                                       %w{filesystem inodes iused ifree iuse mounted_on}
                                                       ),
                                       :filesystem
                                       )
      
      filesystems
    end


  end
end
