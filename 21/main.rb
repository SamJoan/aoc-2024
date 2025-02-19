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

$char_pos_cache = {}

def get_char_pos(keypad, char)
  key = [keypad, char]
  return $char_pos_cache[key] if $char_pos_cache[key]

  keypad.each.with_index do |line, y|
    a_x = line.index(char)
    if a_x
      return_value = [a_x, y]
      $char_pos_cache[key] = return_value
      return return_value
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

  def initialize(cost, current_position, target_position, input, invert_strategy)
    @cost = cost
    @current_position = current_position
    @target_position = target_position
    @input = input
    @invert_strategy = invert_strategy
  end

  def get_values
    return @cost, @current_position, @target_position, @input, @invert_strategy
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
    @invalid_location = get_char_pos(@pad, '.')
    @paths = {}
  end

  # Couldn't figure out, got the answer from here.
  # https://www.reddit.com/r/adventofcode/comments/1hj2odw/comment/m34dspx/?share_id=SRK0wfyf0Y0GS3LcaC36m&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1
  def get_next_optimal_direction(current_position, target_position, invert_strategy=false)
    current_x, current_y = current_position
    target_x, target_y = target_position
    invalid_x, invalid_y = @invalid_location

    moving_left = current_x > target_x
    strategy = moving_left ? :horizontal_first : :vertical_first

    if invert_strategy
      strategy = strategy == :horizontal_first ? :vertical_first : :horizontal_first
    end

    if strategy == :horizontal_first
      if current_x != target_x
	if current_x > target_x
	  return '<'
	else
	  return '>'
	end
      end

      if current_y != target_y
	if current_y > target_y
	  return '^'
	else
	  return 'v'
	end
      end
    elsif strategy == :vertical_first
      if current_y != target_y
	if current_y > target_y
	  return '^'
	else
	  return 'v'
	end
      end

      if current_x != target_x
	if current_x > target_x
	  return '<'
	else
	  return '>'
	end
      end
    end

    raise "unable to find next dir."
  end

  def get_optimal_path(current_position, target_position)
    original_position = current_position
    key = [current_position, target_position]
    if @paths.has_key?(key)
      return @paths[key]
    else
      mh = []
      mh << Element.new(0, current_position, target_position, [], false)

      optimal_path = nil
      loop do
        elem = mh.shift

        break if !elem

        cost, current_position, target_position, input, invert_strategy = elem.get_values
        curr_x, curr_y = current_position

        if current_position == target_position
          optimal_path = input
          next
        end

        direction = get_next_optimal_direction(current_position, target_position, invert_strategy)
        next_position = get_next_position(direction, current_position)

        next_x, next_y = next_position
        if @pad[next_y][next_x] == '.' # irrecoverable error, invert strategy.
          mh << Element.new(0, original_position, target_position, [], true)
          next
        end

        next_input = input.dup.append(direction)

        mh << Element.new(cost + 1, next_position, target_position, next_input, invert_strategy)
      end

      raise "Can't calculate optimal path?" if optimal_path == nil

      @paths[key] = optimal_path
      return optimal_path
    end
  end

  def prepopulate_cache
    a_position = get_char_pos(@pad, 'A')
    bad_position = get_char_pos(@pad, '.')
    @pad.each.with_index do |line, y|
      line.each.with_index do |char, x|
        current_position = [x, y]
        if current_position == a_position || current_position == bad_position
          next
        end

        get_optimal_path(current_position, a_position)
        get_optimal_path(a_position, current_position)
      end
    end
  end
end

def solve(keypad, required_output, simulate_interim_a=false)
  original_output = required_output
  required_output = required_output.dup
  last_position = get_char_pos(keypad, 'A')
  a_position = get_char_pos(keypad, 'A')

  cache = $caches[keypad]
  parts = {}
  required_output.each do |key, value|
    key.each do |char|
      current_position = last_position
      target_position = get_char_pos(keypad, char)
      part = cache.get_optimal_path(current_position, target_position)

      last_position = target_position

      parts[part] = 0 if !parts[part]
      parts[part] += value
    end

    if simulate_interim_a
      part = cache.get_optimal_path(last_position, a_position)
      last_position = a_position

      parts[part] = 0 if !parts[part]
      parts[part] += value

    end
  end

  parts
end

def calculate_length(optimal_output)
  length = 0
  optimal_output.each do |part, amount|
    length += (part.length + 1) * amount
  end

  length
end

def n_keypads(optimal_output, repeat, optimal=true)
  repeat.times do |nb|
    optimal_output = solve($keypad, optimal_output, true)
  end

  calculate_length(optimal_output)
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
  output_dict = {}
  original_required_output.each { |c| output_dict[[c]] = 0 if !output_dict[[c]] ; output_dict[[c]] += 1  }
  optimal_output = solve($numpad, output_dict)

  number_of_repeats = ARGV[1].to_i
  raise "Missing ARGV[1]" if number_of_repeats <= 0
  shortest_length = n_keypads(optimal_output, number_of_repeats)

  numeric_value = original_required_output.join[0..-2].to_i

  puts "Shortest length input for '#{numeric_value}' is #{shortest_length}"
  puts "total += (#{shortest_length} * #{numeric_value})"

  total += shortest_length * numeric_value
end

puts "Total: #{total}"
