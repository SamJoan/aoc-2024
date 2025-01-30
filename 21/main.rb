$numpad = [
  "789".chars,
  "456".chars,
  "123".chars,
  ".0A".chars
]

$keypad = [
  ".^A".chars,
  "<v>".chars
]

required_pads = [
  $numpad,
  $keypad,
  $keypad
]

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

class Element
  attr_accessor :cost

  def initialize(cost, strategy, current_position, target_position, input)
    @cost = cost
    @strategy = strategy
    @current_position = current_position
    @target_position = target_position
    @input = input
  end

  def get_values
    return @cost, @strategy, @current_position, @target_position, @input
  end
end

def get_next_position(direction, current_position)
  current_x, current_y = current_position

  case direction
  when '<'
    current_x -= 1
  when '>'
    current_x += 1
  when '^'
    current_y -= 1
  when 'v'
    current_y += 1
  end

  return [current_x, current_y]
end

class Paths
  def initialize(pad)
    @pad = pad
    @paths = {}
  end

  def get_reasonable_directions(strategy, current_position, target_position)
    # XXX: Fix issue when going from 7 to 0
    current_x, current_y = current_position
    target_x, target_y = target_position
    directions = []

    if strategy == :horizontal_first
      if current_x != target_x
        if current_x > target_x
          return ['<']
        else
          return ['>']
        end
      end

      if current_y != target_y
        if current_y > target_y
          return ['^']
        else
          return ['v']
        end
      end
    elsif strategy == :vertical_first
      if current_y != target_y
        if current_y > target_y
          return ['^']
        else
          return ['v']
        end
      end

      if current_x != target_x
        if current_x > target_x
          return ['<']
        else
          return ['>']
        end
      end
    else
      raise "Unknown strategy."
    end

    raise "Unable to direction proper."
  end

  def get_possible_paths(current_position, target_position, optimal)
    key = [current_position, target_position]
    if @paths.has_key?(key)
      return @paths[key]
    else
      mh = []
      mh << Element.new(0, :vertical_first, current_position, target_position, [])
      mh << Element.new(0, :horizontal_first, current_position, target_position, [])

      possible_paths = []
      loop do
        elem = mh.shift

        break if !elem

        cost, strategy, current_position, target_position, input = elem.get_values
        curr_x, curr_y = current_position

        if current_position == target_position
          possible_paths.append(input)
          next
        end

        reasonable_directions = get_reasonable_directions(strategy, current_position, target_position)
        reasonable_directions.each do |direction|
          next_position = get_next_position(direction, current_position)

          next_x, next_y = next_position
          next if @pad[next_y][next_x] == '.' # irrecoverable error

          next_input = input.dup.append(direction)

          mh << Element.new(cost + 1, strategy, next_position, target_position, next_input)
        end

      end

      possible_paths = possible_paths.uniq

      if possible_paths.length > 1 && optimal
        possible_paths = find_optimal_path(possible_paths)
      end

      @paths[key] = possible_paths
      return possible_paths
    end
  end

  def find_optimal_path(possible_paths)
    shortest_length = -1
    shortest_path = []
    possible_paths.each do |path|
      outputs = [path]
      length = n_keypads(outputs, 2, false)

      if length == shortest_length
        shortest_path.append(path)
      elsif length < shortest_length || shortest_length == -1
        shortest_length = length
        shortest_path = [path]
      end
    end

    shortest_path
  end

  def prepopulate_cache
    a_position = get_char_pos(@pad, 'A')
    @pad.each.with_index do |line, y|
      line.each.with_index do |char, x|
        current_position = [x, y]
        get_possible_paths(current_position, a_position, true)
        get_possible_paths(a_position, current_position, true)
      end
    end
  end
end

def solve(keypad, required_output, optimal=true)
  required_output = required_output.dup
  current_position = get_char_pos(keypad, 'A')
  target_position = get_char_pos(keypad, required_output[0])

  cache = $caches[keypad]
  parts = []
  loop do
    possible_paths = cache.get_possible_paths(current_position, target_position, optimal)
    parts.append(possible_paths)

    required_output.shift

    break if required_output.length == 0

    current_position = target_position
    target_position = get_char_pos(keypad, required_output[0])
  end

  final_outputs = []
  outputs = parts.shift
  loop do
    next_part = parts.shift
    if !next_part
      outputs = outputs.map {|x| x + ["A"]}
      break
    end

    next_outputs = []
    outputs.each do |output|
      next_part.each do |next_part|
        assembled = output + ["A"] + next_part
        next_outputs.append(assembled)
      end
    end

    outputs = next_outputs
  end

  outputs
end

def n_keypads(outputs, repeat, optimal=true)
  repeat.times do |nb|
    new_outputs = []
    outputs.each do |required_output|
      solutions = solve($keypad, required_output, optimal)
      solutions.each do |solution|
        new_outputs.append(solution)
      end
    end

    outputs = new_outputs
  end

  shortest_length = -1
  outputs.each do |output|
    shortest_length = shortest_length == -1 || output.length < shortest_length ? output.length : shortest_length
  end

  shortest_length
end

required_outputs_from_file = parse_inputs(ARGV[0])

$caches = {}
$caches[$numpad] = Paths.new($numpad)
$caches[$keypad] = Paths.new($keypad)

$caches[$numpad].prepopulate_cache
$caches[$keypad].prepopulate_cache

total = 0
required_outputs_from_file.each do |required_output|
  original_required_output = required_output.dup
  outputs = solve($numpad, required_output)

  shortest_length = n_keypads(outputs, 2)

  numeric_value = original_required_output.join[0..-2].to_i

  puts "Shortest length input for '#{numeric_value}' is #{shortest_length}"
  puts "total += (#{shortest_length} * #{numeric_value})"

  total += shortest_length * numeric_value
end

puts "Total: #{total}"
