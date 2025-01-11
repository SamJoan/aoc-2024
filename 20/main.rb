require "algorithms"
require "set"
include Containers

DIRECTIONS = [:up, :down, :left, :right]

class Element
  attr_accessor :cost

  def to_s
    "<Element #{@cost} #{@position[0]},#{@position[1]}>"
  end

  def initialize(cost, position, last_direction)
    @cost = cost
    @position = position
    @last_direction = last_direction
  end

  def get_values
    return @cost, @position, @last_direction
  end
end

def parse_map(filename)
  start_location = nil
  end_location = nil
  map = []
  IO.readlines(filename).map(&:strip).each.with_index do |line, y|
    start_index = line.index("S")
    end_index = line.index("E")

    if start_index
      start_location = [start_index, y]
      line[start_index] = '.'
    end

    if end_index
      end_location = [end_index, y]
      line[end_index] = '.'
    end

    map.append(line)
  end

  start_location.freeze
  end_location.freeze
  map.freeze

  return start_location, end_location, map
end

def debug_map(map, steps)
  map.each.with_index do |line, y|
    line = line.dup()
    steps.each do |s|
      s_x, s_y = s
      if s_y == y
        line[s_x] = 'X'
      end
    end

    puts line
  end
end

def step(map, current_position, direction)
  next_x, next_y = current_position

  if direction == :up
    next_y -= 1
  elsif direction == :down
    next_y += 1
  elsif direction == :left
    next_x -= 1
  elsif direction == :right
    next_x += 1
  else
    raise "Unknown direction #{direction}"
  end

  return nil if (next_x.negative? || next_x > map[0].length - 1) ||
    (next_y.negative? || next_y > map.length - 1)

  return next_x, next_y
end

def opposite(direction)
  if direction == :left
    return :right
  elsif direction == :right
    return :left
  elsif direction == :up
    return :down
  elsif direction == :down
    return :up
  else
    raise "Unknown direction #{direction}"
  end
end

def get_start_end_pair(map, steps)
  s, e = nil
  steps.each do |step|
    x, y = step
    is_hash = map[y][x] == '#'
    if !s && is_hash
      s = step
      e = step
    elsif is_hash
      e = step
    end
  end

  return s, e
end

def navigate(map, target_location, start_location)
  
  mh = MinHeap.new { |x, y| (x.cost <=> y.cost) == -1 }
  mh.push(0, Element.new(0, start_location, nil))

  solutions = []
  already_added = {}
  original_steps = []
  steps = []
  loop do

    elem = mh.min!

    break if !elem

    cost, location, last_direction = elem.get_values
    
    directions = DIRECTIONS.dup
    directions = directions - [opposite(last_direction)] if last_direction

    steps = steps.dup
    steps.append(location)

    if location == target_location
      solutions.append(cost)
      original_steps = steps

      break
    end

    directions.each do |direction|
      next_pos = step(map, location, direction)

      next if !next_pos

      next_x, next_y = next_pos
      if map[next_y][next_x] != '#'
        mh.push(cost + 1, Element.new(cost + 1, next_pos, direction))
      end
    end
  end

  return solutions, original_steps
end

def find_valid_teleportations(steps, step, teleport_radius)
  within_radius = {}
  steps.each do |destination|
    x_a, y_a = step
    x_b, y_b = destination
    manhattan = (x_a - x_b).abs + (y_a - y_b).abs

    if manhattan <= teleport_radius && manhattan >= 2
      within_radius[manhattan] = [] if !within_radius[manhattan]
      within_radius[manhattan].append(destination)
    end
  end

  within_radius
end

def navigate_while_cheating(map, steps, original_cost, teleport_radius, expected_savings)
  steps_pos = {}
  steps.each.with_index do |step, i|
    steps_pos[step] = i
  end

  cost = 0
  solutions = []
  steps.each do |step|
    puts cost if cost % 100 == 0 && cost != 0

    teleps = find_valid_teleportations(steps, step, teleport_radius)
    teleps.each do |manhattan, coords|
      coords.each do |dest_coord|
        remaining_after_dest = steps.length - 1 - steps_pos[dest_coord]
        final_cost = cost + manhattan + remaining_after_dest
        solutions.append(final_cost) if final_cost <= original_cost - expected_savings
      end
    end

    cost += 1
  end

  solutions
end

start_location, target_location, map = parse_map(ARGV[0])

solutions, steps = navigate(map, target_location, start_location)
original_cost = solutions[0]

teleport_radius = ARGV[1].to_i
expected_savings = ARGV[2].to_i
raise "radius" if teleport_radius < 2
raise "expected_savings" if teleport_radius < 1
solutions = navigate_while_cheating(map, steps, original_cost, teleport_radius, expected_savings)

p solutions.map {|s| original_cost - s }.tally
puts solutions.length
