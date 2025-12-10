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

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def distance_to(point)
    Math.sqrt(
      (x - point.x).pow(2) +
      (y - point.y).pow(2)
    )
  end

  def to_string
    [x, y].join(", ")
  end
end

class Distance
  attr_reader :point_1, :point_2, :value
  def initialize(point_1, point_2)
    @point_1  = point_1
    @point_2  = point_2
    @value    = point_1.distance_to(point_2)
  end
end

class Rect
  def self.area(p1, p2)
    width  = (p1.x - p2.x).abs + 1
    height = (p1.y - p2.y).abs + 1

    width * height
  end
end


FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  ## READING THE INPUT
  points = []
  largest_area = nil

  InputStreamer.new(file_path).for_each do |line|
    x, y = line.split(",").map(&:to_i)
    new_point = Point.new(x, y)

    # brute force calculations of rect area to find the largest rect
    points.each do |point|
      area = Rect.area(new_point, point)

      if largest_area.nil? || largest_area < area
        largest_area = area
      end
    end

    points << new_point
  end


  largest_area
end

puts solve
