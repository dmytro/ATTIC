class CapistranoDeployGenerator < Rails::Generators::NamedBase  
  
  SUBMODULES = {  
    recipes: "git@github.com:dmytro/capistrano-recipes.git",
    :"chef-solo" => "git@github.com:dmytro/chef-solo.git"
  }

end
