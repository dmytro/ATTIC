# @title AWS Deploy Configuration

# Configuration steps

For detailed description of configuration see Configuration section.

1. Create `secret.yml` credentials file. This file is not included with the distribution, see *Security Note*.
   - See also documentation on multi applcaition configuration
1. In `environment.yml` file, adjust `:ec2` section:
   1. `:instance_type`
   1. `:security_group`
   1. `:instance`  section
      1. `:instance[:create]` - Boolean, true or false. If this is set to false, then `:instance[:id]` should be provided. When `true`, then new instance with new ID is created. 
      1. `:instance[:key_name]`  - SSH key name, see below.



**Note on variable names** All variables here presented in their Ruby notation, while in configuration file YAML format is used. All configuration merged hierarchically into constant `APP`. Accordingly variable `APP[:ec2][:instance_type]` corresponds in YAML syntax to:

    ---
    :ec2:
      :region:


All configuration is located in `./config` directory relative to the project path.

**Security Note**: File `secret.yml`, `secret.*.yml` and all `*.pem` files contain your private information, never commit them to any publicly accessible repository. For this reason they are included in `.gitignore`.


# Configuration files

- `environment.yml` - main configuration file
- `secret.yml` - AWS security credentials, access key id and secret access key. This is your AWS access key used with AWS SDK. See `secret.yml.sample` file for formatting example. 
- `environment.rb` - Ruby code to load and merge all configuration

# SSH keys

- `NAME.pem` - your SSH private key to access AWS EC2 server. This key should exist and its name should be configured in `environment.yml` file in `APP[:ec2][:instance][:key_name]`.


## Multi application configuration

AWS Deploy can support configurations for multiple applicaitons. This is achieved by overriding environment defaults with custom YAML file. Any of the settings in `environment.yml` file can be overwritten by cutom configuration.

To use custom congiguration file:

1. Add configuration line in main `environment.yml` file:

   ```
       :app:
         :config: custom_config.yml
   ```
   
2. Create configuration file and specify custom per-application configuration options:
   - secret file
   - PEM ssh key file
   - domain etc
   
   ```
       :app:
         :secret: secret.custom.yml
       :ec2:
         :security_group: default
         :instance:
            :key_name: custom_key
   ```            

Secret file name should have format `secret.*.yml`, in this case it is already included in `.gitignore` file. Otherwise, if you decide to use different filename, please amke sure to include in in gnore list. See *Security Note* above.

Using this configuration per-application configs can be commited to different git branches and managed separately.


# Sections of the configuration

## :app

This is generic configuration section applicble for whole aws-deploy application. Things like log file, local Marshal stoga file and deployment steps are configured here.

### Deployment steps

It is possible to disbale certain steps in the deployment workflow. If, for example, you only need to setup server and then prefer to do deployment manually you can disable Capistrano step. To do this simply set step you want tp disable to `false`:

    :steps:
      :capistrano: false

## :ec2

Configuration for AWS EC2 SDK and AWS instance. This configuration also contains some options that are used in other sections, like, for example, SSH key name and path.

## :chef

- `dir:` Location of chef solo repository, relative to the aws-deploy path. Example: `./lib/chef-solo`
- `:json:` - JSON configuration file name for chef-solo deployment (Example: webserver.json)
- `:librarian_install:` - Boolean flag - to run `librarian-chef install` in chef-solo repository before installation or not. In most cases, you'd want to set it to `true`, but if you have local changes, you can prevent overwriting them by setting flag to `false`.

## :cap

- `directory:` - Rails application directory to run deployment from. Local directory either relative to the root of `aws-deploy` or absolute UNIX path.
- `branch:` - branch to deploy, used in Capistrano deployment configuration. Can be overwritten by command line switch `--branch`.

## Route 53 configuration

DNS configuration is included as subsection in EC2 configuration (APP[:ec2][:dns]).

- `domain:` - It's a Route 53 hosted zone name for your application. It must exist and you must have access to manage it.
- `subdomain:` - usually this is your branch name that you want to deploy for testing. AWS-Deploy will create DNS subdomain with this name under Route 53 domain (above). You can specify either a sub-domain name explicitly here or put a symbol `:branch` as configuration option. In a ltter case branch name configured for deployment is used as sub-domain name. This option can be overridden by `--dns` command line option.
- `ttl:` - DNS TimeToLive in seconds for DNS subdomain, usually 300 sec (5 min) is good enough.


### Deployment configuration generation

Multistage deploy configuration files for Capistrano are generated from ERB templates.

Array of names of stages for which configuration file is generated from ERB are defined by `APP[:cap][:generate_config]` variable. Stages are names used with Capistrano multistage extension, they should be declared in `./<RAILS>/config/deploy.rb` like:

     require 'capistrano/ext/multistage'
     set :stages, %w(development production staging)

* Generated configuration is saved in `./<RAILS>/config/deploy/#{stage}.rb` file;
* Source ERB template should exist in `./aws-deploy/config/deploy/#{stage}.rb.erb` file;
* Configurations are generated only for those stages that are listed in `APP[:cap][:stage]` variable.
