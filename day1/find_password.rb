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
  LOCK_STATES = 0..99.freeze
  attr_reader :current_position

  def initialize
    @current_position = 50
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
    @current_position = (current_position - position) % LOCK_STATES.size
  end

  def move_right(position)
    @current_position = (current_position + position) % LOCK_STATES.size
  end
end


FILE_PATH = 'input.txt'
def crack_password
  lock = Lock.new
  password = 0

  streamer = InputStreamer.new(FILE_PATH)
  streamer.for_each do |line|
    lock.move(line)

    password += 1 if lock.current_position.zero?
  end

  puts "Password: #{password}"
  password
end

crack_password
