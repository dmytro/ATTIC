module AWS
  # Some helper functions for AWS::EC2 class
  class EC2

    class Instance <Resource
      def running?
        status == :running
      end
    end

    class SecurityGroupCollection
      
      # Find ID of securitygroup fy name
      def find name
        self.each do |g|
          return g if name == g.name
        end
      end
    end

  end
end
