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


FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  # Reading the lines
  lines = []
  InputStreamer.new(file_path).for_each do |line|
    lines << line.split("")
  end

  # The operators shouldn't care about the spaces
  # they will still be ordered properly
  operators = lines.pop.join.split.compact

  # Reading the numbers
  # We need to keep the order of the spaces
  # To achieve this we will start consuming charachters from all the lines at the same time
  # the calculation is done when all the charachteres are spaces or newlines.

  results = operators.reverse.map do |op|
    # initialize the result with the identity element of the operator
    calc_result = op == "*" ? 1 : 0

    # keep poping the last element/column from each line and turn them into a number
    # stop when all the columns are spaces
    while true
      number_str = lines.map { |line| line.pop }.join.strip

      break if number_str.empty?

      number = number_str.chomp.to_i

      case op
      when "*"
        calc_result = calc_result * number
      when "+"
        calc_result = calc_result + number
      end
    end

    calc_result
  end.sum
end

puts solve
