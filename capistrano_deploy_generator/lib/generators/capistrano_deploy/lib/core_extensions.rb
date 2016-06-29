class String
  def to_bool
    return true if self =~ (/^(yes|y)$/i)
    return false if self =~ (/^(no|n)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

