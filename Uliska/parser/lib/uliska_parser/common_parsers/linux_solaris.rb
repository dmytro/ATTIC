module Uliska
  class Parser

      # Parser for df -k command
      def self.df_parser
        #   Filesystem           1K-blocks      Used Available Use% Mounted on
        #   /dev/sda1              7867856   1104656   6363536  15% /
        space_separated raw.df[1..-1],  %w{ filesystem blocks used available use mounted_on }
      end
      
  end
end
