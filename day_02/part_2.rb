# To solve this part whenever we get a number range
#
# 1. we split it first in multiple sub-ranges of the same digit_length
# Ex: Range 000-99999 => [000-999, 1000-9999, 10000-99999]
#
# 2. For a specific subrange we find the number of ways we can split the range in chunks
# sub-range 000-999 => 3digits => 0-0-0
# sub range 1000-999 => 4 digits => 00-00 OR 0-0-0-0
#
# 3. For each chunking we find the lowest and the maximum number that are possible to have in that chunk
#   we can't go lower than the first chunk of the from number
#   we can't go higher than the first chunk of the to number
#
# 4. we go from min to max doing: i => x.repeat(number-of-chunks) to get the bigger number
#   we check if that number is in the range, if yes we add it to the invalid numbers

class Range
  attr_reader :from, :to, :str, :from_str, :to_str

  def initialize(range_str)
    @str = range_str
    @from_str, @to_str = range_str.match(/(\d+)-(\d+)/).captures
    @from = @from_str.to_i
    @to = @to_str.to_i
  end

  def digit_lengths
    from_digit_length..to_digit_length
  end

  def from_digit_length
    from.digits.size
  end

  def to_digit_length
    to.digits.size
  end

  def sub_ranges
    @sub_ranges ||= get_sub_ranges
  end

  def get_sub_ranges
    subranges = []

    digit_lengths.each do |length|
      next if length < 2 # we don't care about 1-digit numbers

      subranges << SubRange.new(self, length)
    end

    subranges
  end
end

# A sub-range within a specific digit length
# E.g.: 10-99 or 5423-9999
class SubRange
  attr_reader :parent_range, :from, :to, :digit_length

  def initialize(parent_range, digit_length)
    @parent_range = parent_range
    @digit_length = digit_length
    # the to number we end with is the minimum between:
    # - the to number of the parent range
    # - the to number in digit_length class (9, 99, 999, 9999, ...)
    @to = [parent_range.to, 10.pow(digit_length) - 1].min

    # the from number we start with is the maximum between:
    # - the from number of the parent range
    # - the from numebr in digit_length class (1, 10, 100, 1000, ...)
    # - the
    @from = [parent_range.from, 10.pow(digit_length - 1)].max
  end

  def digit_length_divisors
    @digit_length_divisors ||= get_digit_length_divisors
  end

  def get_digit_length_divisors
    divisors = []
    2.upto(digit_length / 2) do |i|
      divisors << i if digit_length % i == 0
    end

    divisors << digit_length

    divisors
  end


  def invalid_numbers
    invalid_numbers = []
    digit_length_divisors.each_with_index do |divisor, index|
      min = @from.to_s[0, digit_length/divisor].to_i
      max = @to.to_s[0, digit_length/divisor].to_i

      min.upto(max).each do |i|
        invalid_number = (i.to_s * divisor).to_i

        # even if we have the min and max, we still have few occasions where the number is out of the range
        # TODO: find a better way to handle the min/max to avoid these checks if possible
        next if invalid_number > @to || invalid_number < @from
        next if invalid_numbers.include?(invalid_number)

        invalid_numbers << invalid_number
      end
    end

    invalid_numbers
  end
end

# read the from line of the input (there is only one line)
FILE_PATH = 'input.txt'
def get_ranges
  File.open(FILE_PATH, 'r') do |file|
    file.readline
        .chomp
        .split(',')
  end
end

def solve
  ranges = get_ranges

  total_invalid = []

  ranges.each do |range_str|
    range = Range.new(range_str)

    range.sub_ranges.each do |sub_range|
      total_invalid << sub_range.invalid_numbers
    end
  end

  total_invalid.flatten.sum
end

puts solve