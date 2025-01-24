require "algorithms"
require "set"
include Containers

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

  def initialize(cost, current_position, target_position, input, remaining_output)
    @cost = cost
    @current_position = current_position
    @target_position = target_position
    @input = input
    @remaining_output = remaining_output
  end

  def get_values
    return @cost, @current_position, @target_position, @input, @remaining_output
  end
end

def get_reasonable_directions(current_position, target_position)
  current_x, current_y = current_position
  target_x, target_y = target_position
  directions = []

  if current_x != target_x
    if current_x > target_x
      directions.append('<')
    else
      directions.append('>')
    end
  end

  if current_y != target_y
    if current_y > target_y
      directions.append('^')
    else
      directions.append('v')
    end
  end

  directions
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

def solve(keypad, required_output)
  mh = MinHeap.new { |x, y| (x.cost <=> y.cost) == -1 }
  current_position = get_char_pos(keypad, 'A')
  target_position = get_char_pos(keypad, required_output[0])

  mh << Element.new(0, current_position, target_position, [], required_output)

  solutions = []
  loop do
    elem = mh.min!

    break if !elem

    cost, current_position, target_position, input, remaining_output = elem.get_values
    current_x, current_y = current_position

    next if keypad[current_y][current_x] == '.' # Irrecoverable exception :( Poor robot..

    #p current_position, target_position
    #p input, remaining_output
    #$stdin.gets
    #p

    if current_position == target_position
      next_required_output = remaining_output.dup
      next_required_output.shift
      next_input = input.dup.append('A')

      if next_required_output.length.zero?
        puts "Found solution #{next_input.join}"
        solutions.append(next_input)
      else
        next_target_position = get_char_pos(keypad, next_required_output[0])
        mh << Element.new(cost + 1, current_position, next_target_position, next_input, next_required_output)
      end

    else
      reasonable_directions = get_reasonable_directions(current_position, target_position)
      reasonable_directions.each do |direction|
        next_position = get_next_position(direction, current_position)
        next_input = input.dup.append(direction)
        mh << Element.new(cost + 1, next_position, target_position, next_input, remaining_output)
      end
    end
  end

  solutions
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

required_outputs_from_file = parse_inputs(ARGV[0])

required_outputs_from_file.each do |required_output_from_file|
  outputs = [required_output_from_file]
  required_pads.each do |required_pad|
    next_outputs = []
    outputs.each do |output|
      solutions = solve(required_pad, output)
      p solutions
      next_outputs.concat(solutions)
    end

    outputs = next_outputs
  end
end
