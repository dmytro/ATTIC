
require 'yaml'
APP = { :config => File.dirname(__FILE__)}

APP[:root] = File.dirname APP[:config]

APP.merge! YAML.load_file("#{APP[:config]}/environment.yml")

# Do we need to merge additional file?
if APP[:app][:config]
  APP.deep_merge! YAML.load_file("#{APP[:config]}/#{APP[:app][:config]}")  
end

##
# Secret file can be defined on configuration file, if not fall back
# to secret.yml
#
secret = APP[:app][:secret] || "secret.yml"
APP[:ec2].merge!  YAML.load_file("#{APP[:config]}/#{secret}")


