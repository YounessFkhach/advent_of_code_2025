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

# we have 100 numbers 0 to 99
class Lock
  LOCK_SIZE = 100.freeze
  attr_reader :current_position, :crossed_zero_count

  def initialize(initial_position)
    @current_position = initial_position
    @crossed_zero_count = 0
  end

  def move(instruction)
    direction, position = instruction.match(/([LR])(\d+)/).captures
    position = position.to_i

    case direction
    when 'L'
      move_left(position)
    when 'R'
      move_right(position)
    else
      raise "Invalid direction: #{direction}"
    end
  end

  private
  def move_left(position)
    new_position = current_position - position
    @crossed_zero_count += crossed_zero_counter(new_position)
    @current_position = new_position % LOCK_SIZE
  end

  def move_right(position)
    new_position = current_position + position
    @crossed_zero_count += crossed_zero_counter(new_position)
    @current_position = new_position % LOCK_SIZE
  end

  def crossed_zero_counter(new_position)
    return 1 if new_position.zero?

    # if we switch direction we automatically have crossed zero once
    if new_position < 0 && current_position > 0
      (new_position.abs / LOCK_SIZE) + 1
    else
      new_position.abs / LOCK_SIZE
    end

  end
end


FILE_PATH = 'input.txt'
def crack_password
  lock = Lock.new(50) # start at middle position 50

  streamer = InputStreamer.new(FILE_PATH)
  streamer.for_each do |line|
    lock.move(line)
  end

  password = lock.crossed_zero_count

  puts "Password: #{password}"
  password
end

crack_password
