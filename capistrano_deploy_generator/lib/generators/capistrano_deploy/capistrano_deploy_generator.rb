require 'rails/generators'
require_relative "config"
require_relative "lib/helpers"
require_relative "lib/core_extensions"

class CapistranoDeployGenerator < Rails::Generators::NamedBase  
  source_root File.expand_path('../templates', __FILE__)


  def runner
    case file_name.to_sym
    when :capify  then capify
    when :modules then install_submodules
    when :deploy  then create_deploy
    when :all
      capify
      install_submodules 
      create_deploy
    end
  end

  private

  def select_asset_precompile
    files = Dir.glob("./config/deploy/recipes/asset**rb").map { |x| File.basename(x, ".rb") }
    loop do 
      choose do |menu|
        menu.readline = true
        menu.header = "Which asset precompile recipe to use: "
        menu.choices(*files) { |f| return f }
        menu.choice("Help") { puts File.read "./config/deploy/recipes/README.assets_precompile.md"}
      end
    end
  end

  def capify
    template "Capfile"
  end

  ##
  # Installs required repositories as project's submodules.
  #
  def install_submodules

    if agree(
             (["OK to add git submodules to your application?",
               "If you select 'No' here some of the fuctionality can be lost",
               "\n"
              ] + 
              SUBMODULES.values).join "\n"
             )

      SUBMODULES.each do |path, submodule|
        run "git submodule add #{submodule} config/deploy/#{path}"
      end
    else
      say "OK. Skipping submodules"
    end
  end

  ##
  # Create deploy rb file
  def create_deploy
    @@tpl = CapistranoDeployGenerator.source_root
    empty_directory "config/deploy"

    say <<-EOF

config/deploy.rb generator

This menu will help you creating deployment configuration file
deploy.rb for Capistrano. It is safe to acceppt defulat values for
most or all questions. Just hit Enter if default is provided.

All values can be changed later in the file itself or you can re-run
generator again.

EOF
    template "deploy.rb.erb", "config/deploy.rb"
    @stages.each do |stage|
      template "staging.rb.erb", "config/deploy/#{stage}.rb"      
    end
    say "Please edit manually configuration of the multi-staging files:"
    @stages.map { |x| say "./confg/deploy/#{x}.rb\n"}
  end

  private 
  
  # 




  # set :application
  def application
    ask ("Application name : ") {  |x| x.default =  File.basename %x{pwd}.chomp }
  end



  # For passthrough scm use also 
  def scm
    @scm = menu_with_default "Which SCM to use for deployment",
    [:git,:passthrough ], :git

    case @scm
    when :passthrough
      %W{ capistrano-deploy-scm-passthrough capistrano-improved-rsync-with-remote-cache}.each do |g|
        append_to_file "Gemfile", "gem '#{g}', :group => :development\n"
      end
    end
    @scm
  end

  ##
  # Try find name of the GIT repo from git remote
  def git_remote
    repos = begin
              %x{git remote --verbose 2>/dev/null}.split("\n").map(&:split).map {|x| [x[0],x[1]] }.uniq
            rescue
              []
            end
    default = repos.find { |x| x.first == 'origin'}
    items = repos.map { |x| x.last }

    menu_with_default "Select repository ", items.compact, default
  end


  # Select version for :rvm_ruby_string
  # 
  # Read `rvm list` and set as default rvm version that is current
  # now.
  def ruby_version
    default = %x{ rvm current}.strip
    items = %x{ rvm ls strings }.split.compact

    ruby = menu_with_default "RVM Ruby version to use for deployment:", items,default
    ruby = ask "Enter alternative RVM Ruby string: " if ruby =~ /Other/
    ruby
  end

  ## 
  # List of the stages for multistage extension and default stage
  #
  def multistage
    @stages = %w(development production staging)
    catch :exit do 
      loop do 
        choose do |menu|
          menu.header = "List stages for multistage deployments"
          menu.prompt = "Type number to delete, 1 to add new, Enter - complete."
          menu.choice '*** Add ***' do 
            @stages << ask("New stage: ")
          end
          menu.hidden("") {  throw :exit }

          menu.choices(*@stages) { |x| @stages.delete x }
        end
      end
    end

    @stages2 = @stages.dup
    { 
      stages: @stages,
      default: menu_with_default("Default stage:", @stages2, "production")
    }
  end

  ##
  # Try to detect DB from confing file and add necessary components.
  def database
    default = begin
                YAML.load_file("config/database.yml")['production']['adapter'].strip
              rescue
                nil
              end
    menu_with_default "Select a database for production:", ["postgres", "mysql", "sqlite3"], default
  end

  def comment_block text
    say text
    text
  end
end
