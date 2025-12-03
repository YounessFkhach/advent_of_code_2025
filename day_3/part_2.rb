# Similar to the Part 1 approach:
# we start by taking the least significant 12 digits as the initial joltage number
# But now instead of doing it in a single loop, we use a recursive structure

## Structure: JoltageNumber class ##
####################################
# JultageNumber class represnts the number value of the N last digits in the string
# Ex: when N=3 a JoltageNumber(12345, 3) represents 12[345] => 345
#
# Each JoltageNumber has a #digit which is the most significant digit of its value
# Ex: for JoltageNumber(12345, 3) => 12[345] => digit = 3
#
# Each JoltageNumber also has a reference to its immediate right JoltageNumber
# Ex: for JoltageNumber(12345, 3) => 12[345] => right = JoltageNumber(12345, 2) => RightJoltageNumber = 123[45]

### Loop: ##
############
# We start by initializing the JoltageNumber with the least significant 12 digits
# Then we iterate backwards through the rest of the digits
# For each digit, we try to set it as the new digit of the current JoltageNumber
# If the new digit is greater than or equal to the current digit:
#   - we set it to the current digit
#   - we pass down our previous digit to the immediate right JoltageNumber
#   - the right JoltageNumber will handle the rest of the digits recursively


## Constructin the final nmuber ##
# To get the final number represented by the JoltageNumber structure
# we call #number on the root JoltageNumber
# This will return the current JoltageNumber's digit to the power of its position
# plus the number returned by its immediate right JoltageNumber (if any)


class InputStreamer
  def initialize(file_path)
    @file_path = file_path
  end

  def for_each
    stream_lines do |line|
      yield line
    end
  end

  private

  def stream_lines
    File.open(@file_path, 'r') do |file|
      file.each_line do |line|
        yield line.chomp
      end
    end
  end
end

BATTERIES_COUNT = 12
class JoltageNumber
  attr_reader :init_value, :position, :digit, :right

  def initialize(init_value, position)
    # the initial value used to create this JoltageNumber
    # XXXXXX => [digit][right number....]
    @init_value = init_value
    # the position of the digit in the number,
    # a position 0 is the least significant digit
    @position = position
    # the digit is the most left digit of the value
    @digit = init_value.to_s.chars.first.to_i

    if position > 0
      # initialize the immediate right number
      righ_init_number = init_value.to_s[1..].to_i
      @right = JoltageNumber.new(righ_init_number, position - 1)
    end
  end

  def digit=(d)
    return if @digit > d

    # pass down the previous digit to the immediate right number
    right.digit = @digit if right

    # assign the new digit
    @digit = d
  end

  def number
    # return the number formed by this digit and all digits to the right
    digit * (10 ** position) + (right ? right.number : 0)
  end
end

class BatteryBank
  attr_reader :digits, :digit_count

  def initialize(digits)
    @digits = digits
    @digit_count = digits.length
  end


  def max_joltage
    first_12_digits = digits[digit_count - BATTERIES_COUNT, digit_count - 1].to_i

    # Initialize the JoltageNumber with the first 12 digits starting from the end
    # and position set to 11 (0 based)
    joltage_number = JoltageNumber.new(first_12_digits, BATTERIES_COUNT - 1)

    # Iterate backwards through the rest of the digits
    # and try to set the new digit, and let the JoltageNumber class handle the rest
    (digit_count - BATTERIES_COUNT - 1).downto(0) do |index|
      current_value = digits[index].to_i

      joltage_number.digit = current_value
    end

    joltage_number.number
  end
end


FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  output = 0

  streamer = InputStreamer.new(file_path)
  streamer.for_each do |line|
    battery_bank = BatteryBank.new(line)

    battery_joltage = battery_bank.max_joltage

    output += battery_joltage
  end

  output
end

puts solve
