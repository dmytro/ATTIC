require "yaml"
require "json"
require 'ostruct'
require 'singleton'

$: << File.dirname(__FILE__)

require 'uliska_parser/extensions'
require "uliska_parser/common_parsers"

module Uliska
  class Parser

    include Singleton

    # Load YAML data string and initialize instance variables.
    def load yaml
      data = YAML::load yaml 
      raise "Cannot load YAML data" unless data

      @raw = @data = @errors = @commands = nil
      @errors = data.delete('__ERRORS__')
      @commands = data.delete('__COMMANDS__')
      @raw = OpenStruct.new data
      @data = { }
    end

    # Read-in YAML inventory file produced by scanner. If file name
    # is not provided read from STDIN.
    def read file=STDIN

      yaml = case file
             when String
               raise "Input file not defined" unless file
               raise "Input file does not exist" unless File.exist? file
               raise "Input file is not readable " unless File.readable? file
               
               File.read(file)
             when IO
               file.read
             end

      raise "Cannot read YAML data" unless yaml
      load yaml
    end
    
    attr_accessor :data, :errors, :commands, :raw, :parsed
    
    # DSL method for parsing data. Reads Hash raw, parsed data
    # assigned to Hash data. Input parameter +symbol+ is key for data
    # Hash. I.e. parse :kernel, will populate hash brunch
    # data[:kernel]. If block is given it's avaluated and result of
    # evaluation is hash data. If no block given, then data from +raw+
    # are copied directly to +data+ without parsing.
    # @param [Symbol or String] Key of the data hash.
    def self.parse symbol
      symbol = symbol.to_sym
      instance.data[symbol] = block_given? ? yield : self.raw.send(symbol)
    end


    # Require the file if file exists under lib/uliska_parser
    # directory. If input parameter is an Array, then use File.join to
    # load file(s) from directory tree: linux.rb, linux/2.rb, etc.
    def self.load_parsers parameter=:generic
      file_name = case parameter
                  when String, Symbol
                    parameter.to_s
                  when Array  
                    File.join parameter.map(&:to_s)
                  end.downcase
      
      file = File.join(File.dirname(__FILE__), 
                       "uliska_parser",
                       file_name,
                       ) + '.rb'
      # Must use load not require, or RSpec fails
      load file if File.exist? file
      self
    end

    private

    def self.raw;  instance.raw  end
    def self.data; instance.data end
    
    # Process colon-separated (or anything-separated) file
    # (/etc/passwd, groups etc) and return parsed data as array of
    # hashes.
    #
    # @param [String or Array] file PATH to file (i.e. key in @raw Hash) or Array with data to process
    # @param [Array]  fields names of fields in the file
    # @param [String] delimiter
    def self.colon_separated in_data, fields, delimiter=':'
      out = case in_data
             when String,Symbol then raw[in_data]
             when Array  then in_data
             end
      return nil unless out

      out.delete_if { |x| x =~ /^\#/} # Delete comments - BSD group
                                      # and passwd files have comments

      out.map { |line| 
        arr = line.strip.split(delimiter, fields.count)
        hsh={ }
        fields.each do |a|
          
          hsh[a.to_sym] = arr.shift.to_num
        end
        hsh
      }
    end

    # @see Uliska::Parser.colon_separated
    def self.space_separated file, fields
      colon_separated file, fields, /\s+/
    end

    # Format similar to vmstat -s output, 
    # vmstat:
    #   - '       4096 bytes per page'
    #   - '      13573 pages managed'
    #   - '       5553 pages free'
    # Converted into Hash
    #  :vmstat=>
    #   {"bytes per page"=>4096,
    #    "pages managed"=>13573,
    #    "pages free"=>5553
    # @param [String, Symbol or Array] data @see self.colon_separated
    # @param [String or Regexp] delimiter @see self.colon_separated, defaults to spaces
    #
    # TODO: for now limiting hash to have only numeric values. How to make it more generic?
    def self.value_label_pairs data, delimiter = /\s+/
      colon_separated(data, [:value, :label], delimiter).inject({ }) { |res,hash| 

        if hash[:value].is_a?(Numeric)
          if hash[:label] =~ /^K\s/ # For lines like: 384636 K total memory (Linux vmstat)
            hash[:label].sub!(/^K\s+/,'')
            hash[:value] *= 1024
          end

          res[hash[:label]] = hash[:value]
        end

        res
      }
    end

  end

end

