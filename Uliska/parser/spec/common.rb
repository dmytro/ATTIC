$: << File.dirname(File.dirname(__FILE__)) + "/lib"
$: << File.dirname(__FILE__)

require "uliska_parser"

DATA_ROOT = File.dirname(File.dirname(__FILE__)) + "/spec/data"

require 'rspec_normalized_hash'
require 'lib/data_structure'
require "lib/filesystems"
require "lib/any_unix"
require "lib/unix_with_sysctl"
require "lib/any_linux"
require "lib/any_linux2"

