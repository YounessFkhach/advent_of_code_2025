# We go with a recursive approach
# Now with a depth first algo
# but now we start from the Joltage state we want, and our target will be everything to 0
# foreach button, we apply the transformation
# pass the new state to the child, and remove that button from it's buttons
# this way we have a tree of all possible combinations
# we stop when we reach all 0s

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
  attr_reader :state, :buttons, :machines, :path
  def initialize(state, buttons, path = [])
    # current joltage state
    @state    = state
    @path     = path
    # joltage state we want to reach
    @buttons  = buttons
    @machines = []
  end
 
  def done?
    # we are done when everything is zero or one of our children is done
    # state.all? { |v| v == 0 } || machines.find(&:done?)
    state.all? { |v| v == 0 }
  end

  # Only buttons that interact with the only the positive joltages are still available to click
  def smallest_joltage_index
    @smallest ||= state.index(smallest_joltage)
  end

  def smallest_joltage
    state.find { |v| v > 0 }
  end

  def available_buttons
    # buttons that interact with smallest joltage
    @available ||= buttons.select do |btn|
      btn.include?(smallest_joltage_index)
    end
  end

  def call
    puts "state: #{state.inspect}, smallest: #{smallest_joltage}, available: #{available_buttons}"
    return if done?
    return if available_buttons.empty?

    create_children_machines
  end

  def create_children_machines
    # children all all the possible valid combinations
    # of available buttons to acheive the smallest joltage

    if available_buttons.size == 1
      btn = available_buttons.last
      new_state = state_after_button(btn, smallest_joltage)
      new_path = path + ([btn] * smallest_joltage)

      return if new_state.find { |v| v < 0 }

      machine = RecursiveMachine.new(
        new_state,
        buttons - [btn],
        new_path
      )

      machines << machine
      machine.call
    else
      available_buttons.each_with_index do |btn|
        new_buttons = buttons - [btn]
        0.upto(smallest_joltage).each do |count|
          new_state = state_after_button(btn, count)
          new_path = path + ([btn] * count)

          next if new_state.find { |v| v < 0 }

          machine = RecursiveMachine.new(
            new_state,
            new_buttons,
            new_path
          )

          machines << machine
          machine.call
        end
      end
    end
  end

  def length
    shortest_path.size
  end

  def shortest_path
    return @path if done?

    return machines.map(&:shortest_path).compact.sort_by { |p| p.size }.first
  end

  def state_after_button(button, count)
    # We decrease the joltage state
    state.each_with_index.map do |value, index|
      button.include?(index) ? value - count : value
    end
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

    machine = RecursiveMachine.new(joltage, buttons)

    machine.call

    puts "length: #{machine.length} path: #{machine.shortest_path}"
    sum += machine.length
  end

  sum
end

puts solve
