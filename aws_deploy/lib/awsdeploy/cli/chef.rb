module AWSDeploy
  class CLI
    include Mixlib::CLI

    #
    # Chef infra deployment
    # ----------------------------------------
    option :chef, :description => "Chef JSON configuration file to deploy",
    :short => '-c JSON',
    :long  => '--chef JSON',
    :proc => Proc.new {  |o| APP[:chef][:json] = o }
    

  end
end
