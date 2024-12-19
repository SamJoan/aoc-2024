
DIRECTIONS = [:left, :right, :up, :down]

def get_next_pos(map, pos, direction)
  next_x, next_y = pos
  if direction == :up
    next_y -= 1
  elsif direction == :down
    next_y += 1
  elsif direction == :left
    next_x -= 1
  elsif direction == :right
    next_x += 1
  else
    raise "Unknown direction."
  end

  if (next_y.negative? || next_y > map.length - 1) ||
      (next_x.negative? || next_x > map[0].length - 1)
    return nil
  end

  return next_x, next_y
end

def get_adjacent(map, visited, island, pos)
  x, y = pos
  if visited[y][x]
    return
  else
    island.append(pos)
    visited[y][x] = true
  end

  char = map[y][x]
  DIRECTIONS.each do |direction|
    next_pos = get_next_pos(map, pos, direction)
    next if !next_pos

    next_x, next_y = next_pos
    next_char = map[next_y][next_x]
    if next_char == char
      get_adjacent(map, visited, island, next_pos)
    end
  end
end

def generate_empty_visited(map)
  visited = {}
  map.each.with_index do |_, y|
    visited[y] = {}
  end
  
  return visited
end

def find_islands(map)
  islands = []
  visited = generate_empty_visited(map)
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      if !visited[y][x]
        pos = [x, y]
        island = []
        get_adjacent(map, visited, island, pos)
        island.sort!
        islands.append(island)
      end
    end
  end

  islands
end

def find_edges(map, island, parsing, pos, directions)
  sides = 0
  directions.each do |direction|
    next_dir = get_next_pos(map, pos, direction)
    is_part_of_island = next_dir && island.include?(next_dir)

    if !parsing[direction] && !is_part_of_island
      parsing[direction] = true
      sides += 1
    elsif parsing[direction] && is_part_of_island
      parsing[direction] = false
    end
  end

  sides
end

def count_sides(map, island)
  sides = 0
  map.each.with_index do |line, y|
    parsing = {}
    line.each_char.with_index do |_, x|
      if island.include?([x, y])
        directions = [:up, :down]
        sides += find_edges(map, island, parsing, [x, y], directions)
      else
        parsing = {}
      end
    end
  end

  map[0].each_char.with_index do |_, x|
    parsing = {}
    map.each.with_index do |_, y|
      if island.include?([x, y])
        directions = [:left, :right]
        sides += find_edges(map, island, parsing, [x, y], directions)
      else
        parsing = {}
      end
    end
  end

  sides
end

map = IO.readlines(ARGV[0]).map(&:strip)

islands = find_islands(map)

score = 0
islands.each.with_index do |island, nb|
  puts "#{nb}/#{islands.length}"
  area = island.length
  sides = count_sides(map, island)
  score += area * sides
end

puts score
