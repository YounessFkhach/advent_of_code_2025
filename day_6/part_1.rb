# First we read the ranges (lines until we hit an empty line)

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


def calc(op, numbers)
  return numbers[0] if numbers.size == 1

  case op
  when "*"
    numbers[0] * calc(op, numbers[1..])
  when "+"
    numbers[0] + calc(op, numbers[1..])
  end
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  ## READING THE INPUT
  lines = []
  InputStreamer.new(file_path).for_each do |line|
    lines << line.split(" ").compact
  end

  operators = lines.pop

  ## RUNNING THE CALCULATION
  result = 0
  operators.each_with_index do |operator, index|
    numbers = lines.map { |line| line[index].to_i }

    result += calc(operator, numbers)
  end

  result
end

puts solve
