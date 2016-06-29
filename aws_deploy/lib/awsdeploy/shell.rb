module AWSDeploy
  class Shell

    ##
    # Simple helper to run shell commands and stream output to
    # terminal
    # 
    # @param [String] command
    # @param [Boolean] stop_on_error
    #
   def run command, stop_on_error=true
      shell = IO.popen("#{command} 1>&2") do |io|
        while (line = io.gets)
          print line if line.index("unknown")
        end
        io.close
        abort " *** Exiting on shell error." if stop_on_error && ($?.to_i != 0)
      end
      self
    end
  end
end
