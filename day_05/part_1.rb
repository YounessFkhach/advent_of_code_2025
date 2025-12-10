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


# a tree node is representative of a range
# it has a range (min, max)
# it has left and right children
class TreeNode
  attr_accessor :min, :max, :left, :right

  def initialize(min, max)
    @min = min
    @max = max
    @left = nil
    @right = nil
  end

  def include?(value)
    included_here = (value >= @min && value <= @max)
    included_here || included_in_siblings?(value)
  end

  def included_in_siblings?(value)
    if value < @min
      return false if @left.nil?

      @left.include?(value)
    else
      return false if @right.nil?

      @right.include?(value)
    end
  end

  def insert(new_min, new_max)
    # if we overlap, expand current range
    if new_min <= @max && new_max >= @min
      expand(new_min, new_max)
    elsif new_max < @min
      # go left
      insert_left(new_min, new_max)
    else
      # go right
      insert_right(new_min, new_max)
    end
  end

  def insert_left(new_min, new_max)
    if left.nil?
      @left = TreeNode.new(new_min, new_max)
    else
      @left.insert(new_min, new_max)
    end
  end

  def insert_right(new_min, new_max)
    if right.nil?
      @right = TreeNode.new(new_min, new_max)
    else
      @right.insert(new_min, new_max)
    end
  end

  def expand(new_min, new_max)
    @min = [@min, new_min].min
    @max = [@max, new_max].max
  end
end

class RangeTree
  def initialize()
    @root = nil
  end

  def insert(min, max)
    if @root.nil?
      @root = TreeNode.new(min, max)
    else
      @root.insert(min, max)
    end
  end

  def include?(value)
    puts "No root node" if @root.nil?
    return false if @root.nil?

    @root.include?(value)
  end
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  range_tree = RangeTree.new
  mode = 0 # 0: reading ranges, 1: reading values to check
  fresh_count = 0

  puts "Reading ranges"
  # Part 1: Read ranges and build the tree
  InputStreamer.new(file_path).for_each do |line|
    # Switch mode on empty line
    if line.strip.empty? && mode == 0
      puts "Switching to value checking mode"
      mode = 1
      next
    end

    # Step 1: we read ranges and build the tree
    if mode == 0
      min, max = line.split('-').map(&:to_i)
      range_tree.insert(min, max)
    else
      # Step 2: we read values to check
      value = line.to_i

      fresh_count += 1 if range_tree.include?(value)
    end
  end

  fresh_count
end

puts solve
