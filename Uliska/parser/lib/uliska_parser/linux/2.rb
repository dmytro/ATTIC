module Uliska
  class Parser

    # @return [Array] of Hash'es: 
    #     { :name => string, :size => int, :used_by_number => int, :used_by => [] }
    parse :kernel_modules do
      out = space_separated(raw.kernel_modules[1..-1], %w{ name size used_by_number used_by})
      out.map{ |x| x[:used_by] = x[:used_by].split(/,/) rescue [] }
      out
    end


  end # Parser
end # Uliska
