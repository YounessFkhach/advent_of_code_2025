# I went for the early backtracking
# as soon as I find a roll in [x, y], I set next step to be [x-1, y-1] to only recalculate the effected  cells
# but maybe this makes it more heavy, I have to try other approaches to compare performance

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

class Line
  attr_reader :line_string
  def initialize(data)
    @data = data.split('')
  end

  def get_rolls_in_range(from, to)
    from.upto(to).count { |i| is_a_roll?(i) }
  end

  def is_a_roll?(index)
    @data[index] == '@'
  end

  def remove_roll_at(index)
    @data[index] = '.'
  end
end

class RollsService
  def initialize
    @cache = []
    @removed = 0
  end

  def add_line(line)
    # add line to cache
    @cache << Line.new(line)
    @line_size ||= line.size
  end


  def analyze
    current_position = [0,0]

    while current_position[0] < @cache.size && current_position[1] < @line_size
      current_line = @cache[current_position[0]]
      is_a_roll = current_line.is_a_roll?(current_position[1])


      if is_a_roll
        # count adjacent rolls
        sum = adjacent_rows_range(current_position).to_a.map do |adj_index|
          columns = adjacent_columns_range(current_position)

          @cache[adj_index].get_rolls_in_range(columns.first, columns.last)
        end.sum - 1


        # remove roll if needed
        if sum < MAX_ROLL_COUNT
          @removed += 1

          # update the cache to remove the roll
          current_line.remove_roll_at(current_position[1])

          # go back in x an y to reanalyze previous positions that will be affected
          next_line   = [current_position[0] - ADJACENT_COUNT, 0].max
          next_column = [current_position[1] - ADJACENT_COUNT, 0].max
          current_position = [next_line, next_column]
          next
        end
      end

      # move to next position or break if we are done
      next_column = current_position[1] + 1
      if next_column >= @line_size
        next_column = 0
        next_line = current_position[0] + 1
        if next_line >= @cache.size
          return @removed
        end
      else
        next_line = current_position[0]
      end

      current_position = [next_line, next_column]
    end
  end

  def adjacent_rows_range(position)
    current_row = position[0]
    from = [current_row - ADJACENT_COUNT, 0].max
    to  = [current_row + ADJACENT_COUNT, @cache.size - 1].min

    (from..to)
  end

  def adjacent_columns_range(position)
    current_column = position[1]
    from = [current_column - ADJACENT_COUNT, 0].max
    to  = [current_column + ADJACENT_COUNT, @line_size - 1].min

    (from..to).to_a
  end
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  service = RollsService.new
  streamer = InputStreamer.new(file_path)


  # register the lines
  streamer.for_each do |line, index|
    service.add_line(line)
  end

  # process lines
  service.analyze
end

puts solve
