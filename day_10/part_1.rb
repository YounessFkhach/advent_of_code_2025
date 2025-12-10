# We go with a recursive approach
# foreach button, we apply the transformation
# pass the new state to the child, and remove that button from it's buttons
# this way we have a tree of all possible combinations
# for optimizations, we only makde the childs current button + 1..end 

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

class RecursiveMachine
  attr_reader :state, :target, :buttons, :machines
  def initialize(state, target, buttons)
    @state    = state
    @target   = target
    @buttons  = buttons
    @machines = []
  end

  def done?
    state.each_with_index.all? { |v, i| target[i] == v }
  end

  def call
    return if done?

    buttons.each_with_index do |button, index|
      machines << RecursiveMachine.new(
        state_after_button(button),
        target,
        buttons_starting(index + 1)
      )
    end

    machines.map(&:call)
  end

  def length
    return 0 if done?

    return Float::INFINITY if machines.empty?

    return 1 + machines.map(&:length).min
  end

  def state_after_button(button)
    state.each_with_index.map do |value, index|
      button.include?(index) ? !value : value
    end
  end

  def buttons_starting(index)
    buttons.select.with_index { |_b, i| i >= index }
  end
end

def parse_input(line)
  target_str, buttons_str, joltage_str = line.match(/\[(?<target>[.#]+)\].{1}(?<buttons>\(.*\)).{1}\{(?<joltage>.*)\}/).captures

  # the target state of the lights: true=on, false=off
  target = target_str.split("").map { |state| state == '#' }

  # turn the buttons str into array: [[0,3], [2] ...]
  buttons = buttons_str.split(" ").map { |btn_str| btn_str.gsub(/\(|\)/, '').split(',').map(&:to_i) }

  joltage = joltage_str.split(',').map(&:to_i)

  [target, buttons, joltage]
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  sum = 0
  InputStreamer.new(file_path).for_each do |line|
    target, buttons, joltage = parse_input(line)
    # initial state is all off
    state = Array.new(target.size, false)

    machine = RecursiveMachine.new(state, target, buttons)
    machine.call
    length = machine.length

    sum += length
  end

  sum
end

puts solve
