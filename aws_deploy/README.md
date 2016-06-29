

AWS Deploy
====================


Ruby libraries and script for one-step deployment Rails applications to AWS:

- build AWS instance
- run chef or chef-solo deployment
- run Capistrano deployment
- create sub-domain in Route53 DNS

Requirements
----------------------

- Ruby 1.9.x
- gem aws-sdk
- chef-solo - installed as git sub-module in `lib/chef-solo`
- capistrano - `./config/deploy.rb` and `/config/deploy/*.rb` for multistage deployment configured for Rails application
    
    
Installation
-------------

See {file:INSTALL.md}

    

### Configuration steps

For detailed description of configuration see Configuration section.

1. Create `secret.yml` credentials file. This file is not included with the distribution, see *Security Note*.
1. In `environment.yml` file, adjust `:ec2` section:
   1. `:instance_type`
   1. `:security_group`
   1. `:instance`  section
      1. `:instance[:create]` - Boolean, true or false. If this is set to false, then `:instance[:id]` should be provided. When `true`, then new instance with new ID is created. 
      1. `:instance[:key_name]`  - SSH key name, see below.

Using
-----------

Execute script  `./deploy.rb --help` to see  command line option or `./deploy.rb --man` to see same with small on-line help.

Script operates on AWS instances:

- deploy
  - create AWS instance or boot existing one
  - run deployment from included `chef-solo` repository.
  - run Capistrano deployment
  - create DNS sub-domain corresponding to deployed application branch.
  
- destroy
  - stop AWS instance
  - optionally terminate it (if `terminate_on_stop` is set to `true`). This will permanently delete EC2 instance from AWS, but instance can be re-created later on next deployment.
  - remove DNS sub-domain from Route53

Configuration
--------------

See {file:CONFIGURATION.md}


AUTHOR
===========

Dmytro Kovalov, 2012-13

dmytro.kovalov@gmail.com

http://dmytro.github.com

Licence
===========

MIT, see {file:LICENSE}
