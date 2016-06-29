module AWSDeploy
  ##
  # Save and load on demand curent status of deployed hosts for
  # current user.
  #
  # Data stored is a subtree APP[:marshal]
  class Marshal

    def initialize hash={ }
      # Path to Marshal file
      @file = case (marshal = APP[:app][:marshal])
               when /^\// then marshal
               else File.join APP[:root], marshal.sub(/^[\.\/]*/,'')
               end

      FileUtils.mkdir_p File.dirname(@file)

      @data = hash
      self.load

      self.store if hash

      APP[:marshal] = @data
    end

    attr_reader :file

    attr_accessor :data

    def store hash={ }
      File.open(file,'w') do |io|
        ::Marshal.dump(@data.deep_merge!(hash), io)
        io.close
      end
      self
    end

    def load
      if File.exist? file
        begin
          @data = @data.deep_merge ::Marshal.load File.read file
        rescue
          FileUtils.rm_f file
          @data ={ }
        end
        APP[:marshal] = @data
      end
      self
    end

    def forget key=nil
      if key
        data.delete(key)
        store data
      else
        @data = { }
        FileUtils.rm_f file
        APP.delete :marshal
      end
      self
    end

  end
end


