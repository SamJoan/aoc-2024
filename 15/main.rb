class CantPush < StandardError; end

def make_bigger(line)
  new_line = ""

  line.each_char do |char|
    if char == "#"
      new_line += "##"
    elsif char == "O"
      new_line += "[]"
    elsif char == "."
      new_line += ".."
    elsif char == "@"
      new_line += "@."
    else
      raise "Unknow char #{char}"
    end
  end

  new_line
end


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
      line = make_bigger(line)
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

    puts line
  end
  $stdin.gets
end

def whole_layer_empty(map, layer)
  layer.each do |pos|
    x, y = pos
    char = map[y][x]
    if char != '.'
      return false
    end
  end

  return true
end

def get_chars_vertically(map, instruction, next_char_pos)
  next_char = map[next_char_pos[1]][next_char_pos[0]]
  if next_char == '['
    opposite = [next_char_pos[0] + 1, next_char_pos[1]]
  elsif next_char == ']'
    opposite = [next_char_pos[0] - 1, next_char_pos[1]]
  else
    raise "what"
  end
  
  next_layer = [next_char_pos, opposite]
  chars = []
  until whole_layer_empty(map, next_layer)
    new_next_layer = []
    chars += next_layer
    next_layer.each do |pos|
      opposite = nil
      next_char_pos = calculate_next_position(map, instruction, pos).dup
      next_char = map[next_char_pos[1]][next_char_pos[0]]
      if next_char == '['
        opposite = [next_char_pos[0] + 1, next_char_pos[1]]
      elsif next_char == ']'
        opposite = [next_char_pos[0] - 1, next_char_pos[1]]
      elsif next_char == "#"
        raise CantPush
      end

      if opposite
        new_next_layer.append(next_char_pos)
        new_next_layer.append(opposite)
      end
    end
    next_layer = new_next_layer
  end

  chars
end

def push!(map, instruction, chars)
  chars = chars.uniq
  if instruction == "^"
    sorted = chars.sort {|x| x[1]} # Sort by Y.
  elsif instruction == "v"
    sorted = chars.sort {|x| x[1]}
  else
    raise "nuh uh..."
  end

  sorted.each do |a|
    b = calculate_next_position(map, instruction, a).dup
    flip_coords(map, a, b)
  end
end

def push_vertically!(map, instruction, original_position)
  next_char_pos = calculate_next_position(map, instruction, original_position).dup
  begin
    chars = get_chars_vertically(map, instruction, next_char_pos)
    push!(map, instruction, chars)
    return next_char_pos
  rescue CantPush
    return original_position
  end
end

def flip_coords(map, a, b)
    a_x, a_y = a
    b_x, b_y = b

    b_val = map[b_y][b_x]
    map[b_y][b_x] = map[a_y][a_x]
    map[a_y][a_x] = b_val
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
      next_position_char = map[next_position[1]][next_position[0]]
      going_vertically = instruction == '^' || instruction == "v"
      if (next_position_char == "[" || next_position_char == "]") && going_vertically
        return push_vertically!(map, instruction, original_position)
      end
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
    flip_coords(map, a, b)
  end

  target_position
end

def process!(map, instructions, current_position)
  instruction = instructions.shift()
  next_position = move!(map, instruction, current_position)
  next_position
end

def calculate_gps_score(map)
  score = 0
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      if char == "["
        s = (100 * y) + x
        score += s
      end
    end
  end

  score
end

map, instructions, starting_position = parse_file(ARGV[0])
next_position = starting_position
until instructions.length.zero?
  next_position = process!(map, instructions, next_position)
end

debug_map(map, next_position)

score = calculate_gps_score(map)

puts score
