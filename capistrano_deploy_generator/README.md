# CapistranoDeployGenerator

Generate deployment configuration to be used with Capistrano.
    
Following options are supported:

* capify - simply run `capify .` command in project 
* deploy - Create config/deploy.rb file and config/deploy directory subtree with required componenets for capistrano.
* modules - Install supporting Git repositories as submodules.


Example:
    rails generate capistrano_deploy deploy


## Installation

Add this line to your application's Gemfile:

    gem 'capistrano_deploy_generator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano_deploy_generator

## Usage

Run to get help:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
rails generate capistrano_deploy 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Submodules

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
rails generate capistrano_deploy modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This command will install github repositories used in the cap deploy. These repositories are installed in `./config/deploy/` subdirectory. 

Following submodules are configured for installation:

* recipes: `git@github.com:dmytro/capistrano-recipes.git` Collection of recipes for Capistrano deployment. Each of the recipe needs to be added to `deploy.rb` file. 
* chef-solo: `git@github.com:dmytro/chef-solo.git` Some of the recipes use Chef-solo configuration to install packages. Also Chef-solo can be used to bootstrap server before deploying. This repository implements chef-solo integration.


### Deploy

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
rails generate capistrano_deploy deploy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Generator for the `deploy.rb` file. Generator uses menu system to create the file. It will guide user throught the set of basic questions and build the file bsed on the user answers.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Author

Dmytro Kovalov

dmytro.kovalov@gmail.com

http://dmytro.github.com

May, 2013

# License

MIT, see LICENSE.txt file
