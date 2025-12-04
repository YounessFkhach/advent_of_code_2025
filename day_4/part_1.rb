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

# how many adjacent digits to consider
# Example
# ..AAA..
# ..AXA..  => means one adjacent digit
# ..AAA..
ADJACENT_COUNT = 1
MAX_ROLL_COUNT = 4

class RollsService
  def initialize
    @cache = {}
  end

  def get_line(index)
    @cache[index]
  end

  def add_line(index, line)
    # add line to cache
    @cache[index] = Line.new(line, index)
  end


  def analyze_line(index)
    current_line = @cache[index]
    from = [index - ADJACENT_COUNT, 0].max
    to  = [index + ADJACENT_COUNT, @cache.keys.max].min

    adjacent_rows_indices = (from..to).to_a

    reduced_line = current_line.transformed_line.each_with_index.map do |value, char_index|
      # we don't calculate if current char is not a roll
      if current_line.is_a_roll?(char_index)
        sum = adjacent_rows_indices.map do |adj_index|
          adj_line = @cache[adj_index]

          adj_line.transformed_line[char_index]
        end.sum - 1

        sum < MAX_ROLL_COUNT ? 'x' : '.'
      else
        '.'
      end
    end

    reduced_line.count { |char| char == 'x' }
  end
end

class Line
  attr_reader :line_string
  def initialize(line_string, index = 0)
    @line_index = index
    @line_string = line_string
  end

  # for each line
  # we transform the values into numbers that match the count of adjacent rolls
  def transformed_line
    @transformed ||= transform_line
  end

  def transform_line
    transformed = ""
    line_string.chars.each_with_index.map do |char, index|
      transform_line_index(index)
    end
  end

  def transform_line_index(index)
    from = [index - ADJACENT_COUNT, 0].max
    to  = [index + ADJACENT_COUNT, line_string.length - 1].min

    adjacent_indices = (from..to).to_a

    adjacent_indices.count do |adj_index|
      is_a_roll?(line_string[adj_index])
    end
  end

  def is_a_roll?(index)
    line_string[index] == '@'
  end
end


FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  service = RollsService.new
  streamer = InputStreamer.new(file_path)


  # register the lines
  line_index = 0
  streamer.for_each do |line, index|
    service.add_line(line_index, line)

    line_index += 1
  end

  # process lines
  output = 0
  0.upto(line_index - 1) do |i|
    output += service.analyze_line(i)
  end


  output
end

puts solve
