# The worst solution yet, literally brute forcing the points
# the most optimized version took 50seconds on my machine
# the original version was taking hours..
#
# I order the rects by area. then I loop through them to find the first one that is fully contained
# fully contained means => all points of it's perimiter
#
# To optimize I went with:
# - check the corners first => if one is not contained then stop
# - check the centers of the lines
# - checking every 1000th point on the perimiter points
# - checking every 100th point on the perimiter points that is not already checked
# - checking every 10th point on the perimiter points that is not already checked
# - checking every 2nd point on the perimiter points that is not already checked
# - checking every point on the perimiter points that is not already checked
#
# NOTE:: a point is included if it has lines on all it's sides

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

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def included?(lines)
    # A point is included if:
    # - it's contained in a line
    # OR
    # - it has lines on all sides

    checks = {
      top: false,
      bottom: false,
      left: false,
      right: false,
    }

    lines.each do |line|
      side = line.position_to_point(self)

      #puts "Point: #{self.to_string} is on: #{side} of #{line.to_string}"
      return true if side == :contained
      next if side == :none

      checks[side] = true

      break if checks.values.all?
    end

    #puts "checks: #{checks.inspect}"
    checks.values.all?
  end

  def to_string
    "{#{[x, y].join(", ")}}"
  end
end

class Line
  attr_reader :p1, :p2, :direction
  def initialize(point_1, point_2)
    # Direction of the line: :row | :column
    @direction = point_1.x == point_2.x ? :column : :row

    # we make sure p1 is before p2 in the axis
    # to make calculations easier
    @p1 = get_smallest(point_1, point_2)
    @p2 = p1 == point_1 ? point_2 : point_1
  end

  def position_to_point(point)
    # Returns the relative position to a point
    # :none => no in the same level
    # :contained => point is part of line
    # :top | :bottom | :left | :right => side of line relative to point
    return :contained if includes?(point)
 
    case direction
    when :row
      if point.x < p1.x || point.x > p2.x
        return :none
      elsif point.y > p1.y
        return :bottom
      else
        return :top
      end
    when :column
      if point.y < p1.y || point.y > p2.y
        return :none
      elsif point.x > p1.x
        return :left
      else
        return :right
      end
    end
  end

  def includes?(point)
    case direction
    when :row
      point.y == p1.y && point.x >= p1.x && point.x <= p2.x
    when :column
      point.x == p1.x && point.y >= p1.y && point.y <= p2.y
    end
  end

  def get_smallest(point_1, point_2)
    case direction
    when :row
      point_1.x < point_2.x ? point_1 : point_2
    when :column
      point_1.y < point_2.y ? point_1 : point_2
    end
  end

  def to_string
    ["Dir: #{direction}", p1.to_string, p2.to_string].join("-")
  end
end

class Rect
  attr_reader :p1, :p2,
              :top_left,
              :top_right,
              :bottom_left,
              :bottom_right

  def initialize(point_1, point_2)
    @p1 = point_1
    @p2 = point_2

    # we define all the corners of the rect
    @top_left     = get_top_left
    @top_right    = get_top_right
    @bottom_left  = get_bottom_left
    @bottom_right = get_bottom_right
  end

  def area
    @area ||= calculate_area
  end

  def calculate_area
    width  = (top_left.x - bottom_right.x).abs + 1
    height = (top_left.y - bottom_right.y).abs + 1

    width * height
  end

  def corners
    [top_left, top_right, bottom_left, bottom_right]
  end

  def centers
    [
      Point.new((top_left.x + top_right.x) / 2,       top_left.y),
      Point.new((bottom_left.x + bottom_right.x) / 2, bottom_left.y),

      Point.new((top_left.x + top_right.x) / 2, (top_right.y + bottom_right.y) / 2),

      Point.new(top_left.x, (top_left.y + bottom_left.y) / 2),
      Point.new(top_right.x, (top_right.y + bottom_right.y) / 2)
    ]
  end

  def all_points
    [
      (top_left.x..top_right.x).map { |x| Point.new(x, top_left.y) },
      (bottom_left.x..top_right.x).map { |x| Point.new(x, bottom_left.y) },
      (top_left.y..bottom_left.y).map { |y| Point.new(top_left.x, y) },
      (top_right.y..bottom_right.y).map { |y| Point.new(top_right.x, y) },
    ].flatten
  end

  def to_string
    [p1.to_string, p2.to_string].join("-")
  end

  private

  # Helpers

  def get_top_left
    x = [p1.x, p2.x].min
    y = [p1.y, p2.y].min

    Point.new(x, y)
  end

  def get_top_right
    x = [p1.x, p2.x].max
    y = [p1.y, p2.y].min

    Point.new(x, y)
  end

  def get_bottom_left
    x = [p1.x, p2.x].min
    y = [p1.y, p2.y].max

    Point.new(x, y)
  end

  def get_bottom_right
    x = [p1.x, p2.x].max
    y = [p1.y, p2.y].max

    Point.new(x, y)
  end
end

class BigRect
  attr_reader :rects, :lines
  def initialize(rects, lines)
    @rects  = rects.sort_by(&:area).reverse
    @size = rects.size
    @lines = lines
  end

  def biggest_rect
    find_biggest_contained_rect
  end

  def find_biggest_contained_rect
    rects.each_with_index do |rect, index|
      contained = rect_contained?(rect)

      return rect if contained
    end
  end

  private

  def rect_contained?(rect)
    # the rect is is considered included/contained if
    # all of it's surface points are include/contained
    corners_included = rect.corners.all? do |corner|
      corner.included?(lines)
    end

    return false unless corners_included

    centers_included = rect.centers.all? do |center|
      center.included?(lines)
    end

    return false unless centers_included

    all_points = rect.all_points
    points_size = rect.all_points.size - 1

    every_1000th_included = (0..points_size).step(1000).all? do |i|
      point = all_points[i]

      point.included?(lines)
    end

    return false unless every_1000th_included

    every_100th_included = (0..points_size).step(100).all? do |i|
      return true if i % 1000  == 0
      point = all_points[i]

      point.included?(lines)
    end

    return false unless every_100th_included

    every_10th_included = (0..points_size).step(10).all? do |i|
      return true if i % 100  == 0

      point = all_points[i]

      point.included?(lines)
    end

    return false unless every_10th_included

    every_2nd_included = (0..points_size).step(2).all? do |i|
      return true if i % 10  == 0

      point = all_points[i]

      point.included?(lines)
    end

    return false unless every_2nd_included

    (0..points_size).step(1).all? do |i|
      return true if i % 2 == 0
      point = all_points[i]

      point.included?(lines)
    end
  end
end

FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  ## READING THE INPUT
  points = []
  # List of rectangles formed by the pairs of points
  rects = []
  # List of lines connecting adjacent points
  lines = []

  InputStreamer.new(file_path).for_each do |line|
    x, y = line.split(",").map(&:to_i)
    new_point = Point.new(x, y)

    # create the line connecting the points
    lines << Line.new(points.last, new_point) if points.last


    # brute force calculations of rect area to find the largest rect
    points.each do |point|
      rects << Rect.new(new_point, point)
    end

    points << new_point
  end

  # connect last point to first
  lines << Line.new(points.last, points.last)

  rect = BigRect.new(rects, lines).biggest_rect

  rect.area
end

puts solve
