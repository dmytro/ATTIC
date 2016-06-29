# Various helper extension for existing classes.

class OpenStruct
  # Access to OpenStruct objects as to Hash
  def [] value
    self.send(value)
  end
end


class Array
  # Calculate sum of a numeric (or what looks like numeric)
  # array. Array elements must be numeric or by respond by +to_f+.
  def sum
    self.map(&:to_f).inject(0,:+)
  end

  # Find sum of column in array of hashes, by key in a hash
  def sum_by key
    self.map { |x| x[key] }.sum
  end

  # Merge array of hashes with similar array by one of the columns (if
  # value for the key are the same). New rows in array2 ade added to
  # self.
  def merge_by array, column
    self.each do |row|
      if mrg = array.find { |x| x[column] == row[column] } rescue nil
        row.merge!(array.delete(mrg))
      end
    end
    (self + array)
  end


end


class Object

  # Convert to one of integer, float etc depending on format. If it
  # does not look like number, return self unmodified.
  def to_num

    number = /^([-+]?\d+(\.\d+)?)(\s?[GMK])?$/

    return self unless self.is_a? String
    return self unless self =~ number 

    decimal, suffix = $2, $3

    self.sub!(number,'\1')

    coeff = case suffix
            when /G/ then 1073741824 
            when /M/ then 1048576 
            when /K/ then 1024
            end

    (coeff || 1) * (decimal ? self.to_f : self.to_i)
    
  end
end
