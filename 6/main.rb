# frozen_string_literal: true

require 'io/console'

class StuckInALoop < StandardError
end

def step(_map, location, direction)
  x, y = location
  case direction
  when :up
    [x, y - 1]
  when :down
    [x, y + 1]
  when :left
    [x - 1, y]
  when :right
    [x + 1, y]
  else
    raise 'Unknown direction.'
  end
end

def turn_right(current_direction)
  case current_direction
  when :up
    :right
  when :right
    :down
  when :down
    :left
  when :left
    :up
  else
    raise 'Unknown direction'
  end
end

def debug(map)
  map.each do |line|
    p line
  end
end

def navigate_map(map, visited_map, location, direction)
  x, y = location
  if !visited_map[y][x].is_a?(Array)
    visited_map[y][x] = []
  else
    raise StuckInALoop if visited_map[y][x].include?(direction)

    visited_map[y][x].append(direction)
  end

  next_x, next_y = step(map, location, direction)
  return if next_x.negative? || next_x > map[0].length - 1 || next_y.negative? || next_y > map.length - 1

  next_char = map[next_y][next_x]
  return navigate_map(map, visited_map, [next_x, next_y], direction) unless next_char == '#'

  next_direction = turn_right(direction)
  navigate_map(map, visited_map, location, next_direction)
end

def gen_visitied_map(map)
  line = ['.'] * map[0].length
  array = []
  (0..map.length - 1).each do |_nb|
    array.append(line.dup)
  end

  array
end

map = nil
start_location = nil
File.open(ARGV[0], 'r') do |f|
  map = f.readlines.map(&:strip)
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      start_location = [x, y] if char == '^'
    end
  end
end

original_map = map
total = 0
original_map.each.with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char != '#'
      puts "#{x},#{y}"
      map = Marshal.load(Marshal.dump(original_map)) # deep_dup
      map[y][x] = '#'
      visited_map = gen_visitied_map(map)
      begin
        navigate_map(map, visited_map, start_location, :up)
      rescue StuckInALoop
        total += 1
      end
    end
  end
end

puts total