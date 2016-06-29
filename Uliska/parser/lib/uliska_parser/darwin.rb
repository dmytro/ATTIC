require 'uliska_parser/generic_bsd' 
require 'uliska_parser/common_parsers/bsd_linux'

module Uliska
  class Parser


    parse :filesystems do
      #
      # Filesystem           1K-blocks      Used     Avail Capacity iused   ifree  %iused  Mounted on
      # /dev/wd0a               806766     57518    708910     8%    2543  100367     2%   /
      # Filter entries like: 
      # map -hosts              0         0         0   100%        0         0  100%   /net
      # map auto_home           0         0         0   100%        0         0  100%   /home
      fss = space_separated raw.inodes[1..-1].reject{ |x| x =~ /^map/}, 
            %w{ filesystem blocks used available use iused ifree iuse mounted_on }

      fss.map { |x| x[:inodes] = x[:iused] + x[:ifree]}
      fss.merge_by(mount_parser, :filesystem)
      # First option in Darwin's mount options is FS type
      fss.map { |f| f[:fs_type] = f[:mount_options] ? f[:mount_options].shift : nil }
      fss
    end

    # @method :vmstat Parse result of vmstat -s into Hash. Parse
    # memory uses result of this, so it should go before +parse :memory+.
    parse :vmstat do 
      raw.vmstat.find{ |x| x =~ /\(page size of (\d+) bytes\)/}
      mem = {"page_size" => $1.to_num}

      colon_separated(:vmstat, [:label, :value]).inject(mem) { |mem,hash| 
        mem[hash[:label]] = hash[:value].to_i
        mem
      }
      mem
    end


    parse :memory do
      {
        :total => sysctl["hw.memsize"],
        :free  => data[:vmstat]["Pages free"] * data[:vmstat]["page_size"] 
      }
    end

    parse :swap do
      #    "vm.swapusage"=>
      #     "total = 2048.00M  used = 1139.05M  free = 908.95M  (encrypted)"

      swap = /total = ([\d\.]+\w)  used = ([\d\.]+\w)  free = ([\d\.]+\w)/.match(sysctl["vm.swapusage"]) { |m|
        m.to_num
      }
      
      {
        :total => swap[1],
        :free => swap[2],
        :used => swap[3],
        :segments => space_separated(:swap, [:size, :device]).map{ |x| 
          x[:used] = x[:size] *= 1024; x 
        }


      }
    end

  end
end
