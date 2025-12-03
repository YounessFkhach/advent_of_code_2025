# To solve the problem:
# we have 2 variables: [tens] and [ones] to represent the two digits of the battery bank voltage [00-99]
#
# we scan the battery bank string from right to left
# we start by taking the last two digits as tens and ones XXXXXXXXX[tens][ones]
#
# as we scan left, if we find a digit greater than or equal to the current tens digit: XXXXXX[tens]XXX[ones]
#
# whenever we find a new tens digit, we check if the previous tens digit can be placed in the ones place, since it was already the max digit between the previous digits
#
# we stop when we reach the start of the string or when both tens and ones are 9 (maxed out)

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

class BatteryBank
  attr_reader :state_string

  def initialize(state_string)
    @state_string = state_string
  end

  def values
    @values ||= state_string.chars.map(&:to_i)
  end

  def max_joltage
    # Take the first two digits as tens and ones
    tens = values[-2]
    ones = values[-1]

    # Iterate backwards through the rest of the digits
    # to find the next largest tens digit
    # and update ones if needed along the way
    (values.length - 3).downto(0) do |index|
      break if tens == 9 && ones == 9 # maxed out

      current_value = values[index]

      if current_value >= tens
        # we found a new tens digit
        # we check if we can put the previous tens digit in the ones place when bigger
        ones = tens if tens > ones

        tens = current_value
      end
    end

    tens * 10 + ones
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

puts "Solve Results: #{solve}"
