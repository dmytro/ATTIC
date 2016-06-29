
require 'uliska_parser/generic_bsd' 

module Uliska
  class Parser


    # @method :vmstat Parse result of vmstat -s into Hash. Parse
    # memory uses result of this, so it should go before +parse :memory+.
    parse :vmstat do 
      value_label_pairs :vmstat
    end


    parse :memory do
      page_size = data[:vmstat]["bytes per page"]
      {
        :page_size => page_size,
        :total => data[:sysctl]["hw.physmem"].to_num,
        :free => data[:vmstat]["pages free"] * page_size
      }
    end

    # Parse output of swapctl -l
    parse :swap do
      # Device        512-blocks     Used    Avail Capacity  Priority
      # /dev/wd0b         166180        0   166180     0%    0
      # /var/swapfile      20480        0    20480     0%    0
      # Total             186660        0   186660     0%
      fields = space_separated :swap, %w{ device size used avail capacity priority}

      block_size = fields.shift[:size].gsub(/[^\d]/,'').to_i
      fields.delete_if { |x| x[:device] == 'Total' }

      total = fields.sum_by(:size).to_i * block_size / 1024
      free = total - (fields.sum_by(:used).to_i * block_size / 1024)

      {:segments => fields, :total => total, :free => free }
    end

    parse :filesystems do
      #
      # Filesystem           1K-blocks      Used     Avail Capacity iused   ifree  %iused  Mounted on
      # /dev/wd0a               806766     57518    708910     8%    2543  100367     2%   /
      fss = space_separated raw.df[1..-1], %w{ filesystem blocks used available use iused ifree iuse mounted_on }
      fss.map { |x| x[:inodes] = x[:iused] + x[:ifree]}
      fss.merge_by(mount_parser, :filesystem)
      fss
    end

  end
end
