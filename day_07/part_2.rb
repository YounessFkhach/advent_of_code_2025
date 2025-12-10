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


class Circut
  def initialize(first_line)
    # board holds the state of the columns: 1: powered, 0: not powered
    @board = Array.new(first_line.size, 0)

    input = first_line.split("").index("S")
    @board[input] = 1
  end

  def advance(line)
    splitters = get_splitters(line)

    # we apply the splitters to the beams
    # for each splitter, we will remove the beam in it's index
    # and add a beam to it's sides
    splitters.each do |splitter|
      split(splitter)
    end

    # we return the new number of beams
    return @board.sum
  end

  def split(index)
    # Apply the split tranformation
    # Instead of setting it to 1, we set the value to the sum of previous values
    # This means each cell holds the sum of beams/possible paths
    @board[index - 1] = @board[index - 1] + @board[index]
    @board[index + 1] = @board[index + 1] + @board[index]
    @board[index]     = 0
  end

  def get_splitters(line)
    splitters = []
    line.split("").each_with_index do |char, index|
      # when we incounter a splitter
      if char == "^"
        # A splitter will split only if there is a beam coming to it
        splitters << index if beam_at? index
      end
    end

    splitters
  end

  def beam_at?(index)
    @board[index] > 0
  end
end


FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  ## READING THE INPUT
  circut = nil
  sum = 0

  lines = []
  InputStreamer.new(file_path).for_each do |line|
    if circut == nil
      # we haven't initialized the the circut board yet
      circut = Circut.new(line)
    else
      sum = circut.advance(line)
    end
  end

  sum
end

puts solve
