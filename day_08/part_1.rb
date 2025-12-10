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

class CircutCounter
  def self.increment
    @@count ||= 0
    @@count += 1
    @@count
  end
end

class Point
  attr_accessor :x, :y, :z, :circut
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
    @circut = nil
  end

  def distance_to(point)
    Math.sqrt(
      (x - point.x).pow(2) +
      (y - point.y).pow(2) +
      (z - point.z).pow(2)
    )
  end

  def connected_to?(point)
    circut && point.circut && point.circut == circut
  end

  def to_string
    ["C#{circut} ", x, y, z].join(", ")
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

class Connector
  attr_reader :points, :size
  def initialize(connections, points, distances)
    @connections = connections
    @distances = distances.sort_by(&:value)
    @points = points
    @size = points.size
  end

  def call
    @distances.each do |distance|
      break if @connections == 1

      p1 = distance.point_1
      p2 = distance.point_2

      @connections -= 1
      next if p1.connected_to?(p2)

      connect(p1, p2)
    end
  end

  def connect(p1, p2)
    if p1.circut && p2.circut
      # both belong to circuts
      # we merge them, meaning:
      # we replace the p2 circut with p1 circut on all points
      old_circut = p1.circut
      points.each do |p|
        p.circut = p2.circut if p.circut == old_circut
      end
    elsif p1.circut
      p2.circut = p1.circut
    elsif p2.circut
      p1.circut = p2.circut
    else
      c = CircutCounter.increment
      p1.circut = c
      p2.circut = c
    end
  end
end

PAIRS = 1000
FILE_PATH = 'input.txt'.freeze
def solve(file_path = FILE_PATH)
  ## READING THE INPUT
  points = []
  distances = []

  InputStreamer.new(file_path).for_each do |line|
    point = Point.new(*line.split(',').map(&:to_i))

    # while reading a new line, we calculate it's distance to all existing lines
    points.each do |other_point|
      distances << Distance.new(point, other_point)
    end

    points << point
  end

  connector = Connector.new(PAIRS, points, distances)

  connector.call

  counts =  points.map(&:circut)
                  .compact
                  .tally
                  .to_a.map { |e| e[1] }.sort.reverse

  counts[0..2].inject(1) { |a, c| a * c }
end

puts solve
