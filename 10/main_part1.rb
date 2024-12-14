
DIRECTIONS = [:up, :right, :down, :left]

def get(map, x, y, direction)
  next_x, next_y = x, y
  if direction == :up
    next_y -= 1
  elsif direction == :down
    next_y += 1
  elsif direction == :left
    next_x -= 1
  elsif direction == :right
    next_x += 1
  else
    raise "Bad direction #{direction}"
  end

  return nil if next_y.negative? || next_y > map.length - 1 ||
    next_x.negative? || next_x > map[0].length - 1

  return next_x, next_y
end

def debug(map, in_x, in_y)
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      if x == in_x && y == in_y
        print("X")
      else
        print(char)
      end
    end
    puts
  end
end

def navigate(map, already_visited, x, y)
  current_value = map[y][x].to_i
  #puts "#{x} #{y}: #{current_value}"
  #debug(map, x, y)
  #$stdin.gets
  if current_value == 9 && !already_visited.include?([x, y])
    already_visited.append([x, y])
    return 1
  end

  total = 0
  DIRECTIONS.each do |direction|
    next_x, next_y = get(map, x, y, direction)

    next if !next_x || !next_y
    #puts "#{x} #{y} dir: #{direction} -> #{next_x}, #{next_y}"

    next_val = map[next_y][next_x].to_i
    #puts "next_val:#{next_val}"
    total += navigate(map, already_visited, next_x, next_y) if next_val == current_value + 1
  end

  return total
end

map = IO.readlines(ARGV[0]).map(&:strip)

trailheads = []
map.each.with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == "0"
      trailheads.append([x, y])
    end
  end
end

total = 0
trailheads.each do |trailhead|
  already_visited = []
  total += navigate(map, already_visited, trailhead[0], trailhead[1])
end

puts total
