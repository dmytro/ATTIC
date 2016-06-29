module AWSDeploy
  class CLI
    include Mixlib::CLI

    #
    # Set additional configuration defaults
    # --------------------------------------------
    use_cap_branch = false
    if APP[:ec2][:dns][:subdomain] == :branch
      APP[:ec2][:dns][:subdomain] = APP[:cap][:branch]
      use_cap_branch = true
    end
      


    #
    # Application CAP deployment
    # ----------------------------------------
    option :branch, :description => "Branch to deploy. If not provided use from config file.",
    :short => '-b BRANCH',
    :long  => '--branch BRANCH',
    :proc => Proc.new { |o| 
      APP[:cap][:branch] = o 
      APP[:ec2][:dns][:subdomain] = o if use_cap_branch
    }

    option :stage, :description => "Deployment stage (production, staging)",
    :short => '-s STAGE',
    :long  => '--cap-stage STAGE',
    :proc => Proc.new {  |o| APP[:cap][:stage] = o }
    

  end
end
