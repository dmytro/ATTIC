#!/usr/bin/env ruby
#
# Copyright 2012 Dmytro Kovalov, dmytro.kovalov@gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.


require_relative 'lib/awsdeploy'
require 'systemu'
cli = AWSDeploy::CLI.new
cli.parse_options

abort "One of --deploy or --destroy options required. See --help" if cli.config.empty?

unless cli.config[:no_test]
  print "Running pre-flight tests ... "
  status, stdout, stderr = systemu 'rspec --fail-fast spec/0*.rb'
  print stdout
  unless status.exitstatus == 0
    print stderr
    exit status.exitstatus
  end
end

case 
when cli.config[:deploy]
  AWSDeploy::CLI.deploy
  exit
when cli.config[:destroy]
  AWSDeploy::CLI.destroy cli.config[:destroy]
  exit
end
