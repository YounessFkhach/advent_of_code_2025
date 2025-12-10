# The entire solution is based on the obeservation that:
# - An ID cannot be invalid if it has an odd number of digits
# - An ID is invalid if it can be expressed as: k * (10^(d/2) + 1)
#  where d is the number of digits and k is an integer
#  This is because such numbers have the same first half and second half
#
# To solve the problem:
#
# Step 1: we split it first in multiple sub-ranges of the same digit_length
# Ex: Range 000-99999 => [000-999, 1000-9999, 10000-99999]
#
# Step 2: For each sub-range with an even digit length d
# we find the first multipiable in that range (a number K such that ID = K * (10^(d/2) + 1))
# we find the last multipliable and the last multipliable in that range
#
# Step 3: We loop from the first multipliable to the last multipliable, calculating the invalid ID each time

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
      # odd lengths have no valid IDs, since they can not be split evenly
      next if length.odd?

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
    raise "Digit length must be even" if digit_length.odd?

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

  def invalid_numbers
    invalid_numbers = []

    first_multipliable.upto(last_multipliable) do |number|
      invalid_number = number * multiplier
      break if invalid_number > to

      invalid_numbers << invalid_number
    end

    invalid_numbers
  end

  def first_multipliable
    (from.to_f / multiplier).ceil
  end

  def last_multipliable
    (to.to_f / multiplier).floor
  end

  def multiplier
    # the full number needs to be a multiplier of 10^(digit_length / 2) + 1 to be invalid
    # example 4 digits need to be a multiplier of 101
    10.pow(digit_length / 2) + 1
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

  total_invalid_sum = 0

  ranges.each do |range_str|
    range = Range.new(range_str)

    range.sub_ranges.each do |sub_range|
    total_invalid_sum += sub_range.invalid_numbers.sum
    end
  end

  total_invalid_sum
end

puts solve
