require 'uliska_parser/generic_bsd' 

module Uliska
  class Parser

    # @method :vmstat Parse result of vmstat -s into Hash. Parse
    # memory uses result of this, so it should go before +parse :memory+.
    parse :vmstat do 
      value_label_pairs :vmstat
    end

    # See script for commands
    # http://www.cyberciti.biz/files/scripts/freebsd-memory.pl.txt

    parse :memory do 
      { :free => sysctl["vm.stats.vm.v_free_count"] * sysctl["hw.pagesize"],
        :total  => sysctl["hw.physmem"]
      }
    end

    # Parse output of swapctl -l
    parse :swap do
      # Device:       1024-blocks     Used:
      # /dev/ad0s1b       34368         0
      # /dev/md0          10240         0    
      fields = space_separated :swap, %w{ device size used }

      block_size = (fields.shift[:size].gsub(/[^\d]/,'').to_i) /1024

      {
        :segments => fields, 
        :total => (total = fields.sum_by(:size).to_i * block_size), 
        :free => (total -  fields.sum_by(:used).to_i) * block_size 
      }
    end

    parse :filesystems do
      #
      # Filesystem           1K-blocks      Used     Avail Capacity iused   ifree  %iused  Mounted on
      # /dev/wd0a               806766     57518    708910     8%    2543  100367     2%   /
      fss = space_separated raw.df[1..-1], %w{ filesystem fs_type blocks used available use iused ifree iuse mounted_on }
      fss.map { |x| x[:inodes] = x[:iused] + x[:ifree]}
      fss.merge_by(mount_parser, :filesystem)
      fss
    end

  end
end

