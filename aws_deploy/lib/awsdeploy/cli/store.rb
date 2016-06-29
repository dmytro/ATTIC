module AWSDeploy
  class CLI
    include Mixlib::CLI

    option :reset, 
    :description => "Forget instance, remove data about specific instance from local memory",
    :short => "-r BRANCH", :long => "--reset BRANCH", :exit => 0 ,
    :on => :head,
    :proc => Proc.new { |br|
      AWSDeploy::Marshal.new.forget(br)
    }


    option :forget, 
    :description => "Forget all data about deployed instances from local memory",
    :short => "-f", :long => "--forget", :exit => 0 ,
    :on => :head,
    :proc => Proc.new {
      AWSDeploy::Marshal.new.forget
    }

    option :list, :description => "List instances in store",
    :short => '-l', :long => '--list', :exit => 0,
    :on => :head,
    :proc => Proc.new { 
      data = AWSDeploy::Marshal.new.data.keys
      if data.empty?
        print "No instances found"
      else
        pp data
      end

    }

    option :show, :description => "Show data for an instance in store",
    :short => '-s BRANCH', :long => '--show BRANCH', :exit => 0,
    :on => :head,
    :proc => Proc.new { |br|
      pp AWSDeploy::Marshal.new.data[br]
    }
  end
end
