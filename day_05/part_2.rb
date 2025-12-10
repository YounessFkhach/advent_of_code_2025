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

  def insert(node)
    return if node.nil?

    # if we overlap, absorb the new node
    if node.max >= @min && node.max <= @max || node.min <= @max && node.min >= @min
      absorb(node)
    elsif node.max < @min
      # go left
      insert_left(node)
    else
      # go right
      insert_right(node)
    end
  end

  def insert_left(node)
    if @left.nil?
      @left = node
    elsif node.max > @left.max
      # new node becomes our imiddiate left child
      node.insert(@left)
      @left = node
    else
      @left.insert(node)
    end
  end

  def insert_right(node)
    if @right.nil?
      @right = node
    elsif node.min < @right.min
      # new node becomes our imiddiate right child
      node.insert(@right)
      @right = node
    else
      @right.insert(node)
    end
  end

  def absorb(node)
    return if node.nil?

    if node.min < @min
      @min = node.min
    end

    if node.max > @max
      @max = node.max
    end

    # handle node's children
    insert(node.left)
    insert(node.right)

    # reinsert current children to ensure proper placement
    left_child = @left
    right_child = @right
    @left = nil
    @right = nil
    insert(left_child)
    insert(right_child)
  end

  def count
    # return current range count plus children counts
    current_count = @max - @min + 1

    left_count = @left.nil? ? 0 : @left.count
    right_count = @right.nil? ? 0 : @right.count

    current_count + left_count + right_count
  end
end

class RangeTree
  def initialize()
    @root = nil
  end

  def insert(min, max)
    node = TreeNode.new(min, max)

    if @root.nil?
      @root = node
    else
      @root.insert(node)
    end
  end

  def count
    return 0 if @root.nil?

    @root.count
  end
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  input_stream = InputStreamer.new(file_path)
  range_tree = RangeTree.new
  fresh_count = 0

  puts "Reading ranges"
  # Part 1: Read ranges and build the tree
  InputStreamer.new(file_path).for_each do |line|
    # break if we hit an empty line
    break if line.strip.empty?

    min, max = line.split('-').map(&:to_i)
    range_tree.insert(min, max)
  end

  # Part 2: count the fresh ids
  range_tree.count
end

puts solve
