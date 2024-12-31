
def parse_file(filename)
  parsing_instructions = false
  map = []
  instructions = ""
  starting_position = nil
  IO.readlines(filename).map(&:strip).each.with_index do |line, y|

    if line == ""
      parsing_instructions = true
      next
    end

    if !parsing_instructions
      x = line.index('@')
      if x
        starting_position = [x, y]
        line[x] = '.'
      end

      map.append(line)
    else
      instructions += line
    end
  end

  return map, instructions.chars, starting_position
end

def calculate_next_position(map, instruction, current_position)
  next_x, next_y = current_position
  if instruction == '<'
    next_x -= 1
  elsif instruction == '>'
    next_x += 1
  elsif instruction == '^'
    next_y -= 1
  elsif instruction == 'v'
    next_y += 1
  else
    raise "Unhandled instruction #{instruction}"
  end

  return nil if next_x.negative? || next_x > map[0].length - 1 
    next_y.negative? || next_y > map.length - 1

  return next_x, next_y
end

def debug_map(map, current_position)
  dup_map = map.dup
  cur_x, cur_y = current_position
  p current_position
  dup_map.each.with_index do |line, y|
    line = line.dup
    if y == cur_y
      line[cur_x] = '@'
    end

    p line
  end
  $stdin.gets
end

def move!(map, instruction, original_position)
  char = nil
  flip = []
  position = original_position
  target_position = nil
  nb = 0
  until char == '.'
    next_position = calculate_next_position(map, instruction, position)

    if nb == 0
      target_position = next_position
    else
      flip.prepend([position, next_position])
    end

    position = next_position
    pos_x, pos_y = position
    char = map[pos_y][pos_x]
    nb += 1

    return original_position if char == '#'
  end

  flip.each do |a, b|
    a_x, a_y = a
    b_x, b_y = b

    b_val = map[b_y][b_x]
    map[b_y][b_x] = map[a_y][a_x]
    map[a_y][a_x] = b_val
  end

  target_position
end

def process!(map, instructions, current_position)
  instruction = instructions.shift()

  next_position = move!(map, instruction, current_position)

  process!(map, instructions, next_position) if instructions.length > 0
end

map, instructions, starting_position = parse_file(ARGV[0])
process!(map, instructions, starting_position)

score = 0
map.each.with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == "O"
      score += (100 * y) + x
    end
  end
end

puts score
