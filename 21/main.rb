class IrrecoverablePanic < StandardError; end

def parse_inputs(filename)
  IO.readlines(filename).map(&:strip).map {|line| line.chars }
end

def get_char_pos(keypad, char)
  keypad.each.with_index do |line, y|
    a_x = line.index(char)
    if a_x
      return [a_x, y]
    end
  end

  raise "No character #{char} in keypad #{keypad}"
end

def debug_keypad(keypad, pos, target_pos, required_solution, output)
  keypad = keypad.dup
  pos_x, pos_y = pos
  target_x, target_y = target_pos

  keypad.each.with_index do |arr, y|
    arr = arr.dup
    arr[pos_x] = 'O' if y == pos_y
    arr[target_x] = 'X' if y == target_y

    puts arr.join
  end
end

def press!(output, current_pos, keypad, keypress)
  current_cursor_x, current_cursor_y = current_pos
  if keypress == '<'
    current_cursor_x -= 1
  elsif keypress == '>'
    current_cursor_x += 1
  elsif keypress == "v"
    current_cursor_y += 1
  elsif keypress == "^"
    current_cursor_y -= 1
  else
    raise "Unknown keypress #{keypress}"
  end

  raise IrrecoverablePanic if keypad[current_cursor_y][current_cursor_x] == "."

  output.append(keypress)

  return [current_cursor_x, current_cursor_y]
end

def solve(keypad, required_solution)
  required_solution = required_solution.dup
  current_cursor = get_char_pos(keypad, "A")
  current_cursor_x, current_cursor_y = current_cursor
  output = []
  loop do
    target_char = required_solution[0]
    break if !target_char

    target_location_x, target_location_y = get_char_pos(keypad, target_char)
    current_cursor_x, current_cursor_y = current_cursor

    debug_keypad(keypad, [current_cursor_x, current_cursor_y], [target_location_x, target_location_y], required_solution, output)
    $stdin.gets

    if current_cursor_x > target_location_x
      begin
        current_cursor = press!(output, current_cursor, keypad, '<')
        next
      rescue IrrecoverablePanic; end
    elsif current_cursor_x < target_location_x
      begin
        current_cursor = press!(output, current_cursor, keypad, '>')
        next
      rescue IrrecoverablePanic; end
    end

    if current_cursor_y < target_location_y
      begin
        current_cursor = press!(output, current_cursor, keypad, 'v')
        next
      rescue IrrecoverablePanic; end
    elsif current_cursor_y > target_location_y
      begin
        current_cursor = press!(output, current_cursor, keypad, '^')
        next
      rescue IrrecoverablePanic; end
    end

    if current_cursor_x == target_location_x && current_cursor_y == target_location_y
      output.append("A")
      required_solution.shift
    end
  end

  output
end

numpad = [
  "789".chars,
  "456".chars,
  "123".chars,
  ".0A".chars
]

keypad = [
  ".^A".chars,
  "<v>".chars
]

required_pads = [
  numpad,
  keypad,
  keypad
]

inputs = parse_inputs(ARGV[0])
total_complexity = 0
inputs.each do |required_output|
  base_output = required_output
  required_pads.each do |keypad|
    required_output = solve(keypad, required_output)
    puts required_output.join
  end

  puts "#{base_output.join}: #{required_output.join} (#{required_output.length})"

  length = required_output.length
  numeric_part = base_output[0..-2].join.to_i
  total_complexity += length * numeric_part
  puts "#{length} * #{numeric_part}"
end

p total_complexity
