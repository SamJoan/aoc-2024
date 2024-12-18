
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

map = IO.readlines(ARGV[0]).map(&:strip)

islands = find_islands(map)

score = 0
islands.each do |island|
  area = island.length
  sides = count_sides(map, island)
  p island
  puts "has #{sides} sides and area #{area}"
  score += area * sides
end

puts score
