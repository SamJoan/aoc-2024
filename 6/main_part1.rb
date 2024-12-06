require 'io/console'

def step(map, location, direction)
  x, y = location
  if direction == :up
    return x, y - 1
  elsif direction == :down
    return x, y + 1
  elsif direction == :left
    return x - 1, y
  elsif direction == :right
    return x + 1, y
  else
    raise "Unknown direction."
  end
end

def turn_right(current_direction)
  if current_direction == :up
    return :right
  elsif current_direction == :right
    return :down
  elsif current_direction == :down
    return :left
  elsif current_direction == :left
    return :up
  else
    raise "Unknown direction"
  end
end

def debug(map)
  map.each do |line|
    p line
  end
end

def navigate_map(map, visited_map, location, direction)
  x, y = location
  visited_map[y][x] = 'X'

  next_x, next_y = step(map, location, direction)
  return if next_x.negative? || next_x > map[0].length - 1 || next_y.negative? || next_y > map.length - 1

  next_char = map[next_y][next_x]
  if next_char == '#'
      next_direction = turn_right(direction)
      return navigate_map(map, visited_map, location, next_direction)
  else
    return navigate_map(map, visited_map, [next_x, next_y], direction)
  end
end

def gen_visitied_map(map)
  line = '.' * map[0].length
  array = []
  (0..map.length - 1).each do |nb|
    array.append(line.dup)
  end
  
  return array
end

map = nil
start_location = nil
File.open(ARGV[0], 'r') do |f|
  map = f.readlines().map { |elem| elem.strip }
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      if char == '^'
        start_location = [x, y]
      end
    end
  end
end

visited_map = gen_visitied_map(map)
navigate_map(map, visited_map, start_location, :up)

total = 0
visited_map.each do |line|
  total += line.count('X')
end

puts total
