class MinHeap
  def initialize
    @data = []
    @dirty = true
  end

  def <<(element)
    @dirty = true
    @data << element
  end

  def swap!(a, b)
    temp = @data[b]
    @data[b] = @data[a]
    @data[a] = temp
  end

  def heapify!(i)
    if @data.length > 1
      smallest = i

      left = 2 * i + 1
      right = 2 * i + 2

      smallest = left if left < @data.length && @data[left].cost < @data[smallest].cost
      smallest = right if right < @data.length && @data[right].cost < @data[smallest].cost

      if smallest != i
        swap!(i, smallest)
        heapify!(smallest)
      end
    end
  end

  def min!
    if @data.length > 0
      if @dirty
        (@data.length / 2 - 1).downto(0) do |i|
          heapify!(i)
          @dirty = false
        end
      end

      elem = @data[0]
      swap!(0, @data.length - 1)
      @data.pop

      heapify!(0)
    end

    elem
  end
end

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

  def initialize(cost, current_position, target_position, input)
    @cost = cost
    @current_position = current_position
    @target_position = target_position
    @input = input
  end

  def get_values
    return @cost, @current_position, @target_position, @input
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

class Paths
  def initialize
    @paths = {}
  end

  def get_possible_paths(keypad, current_position, target_position)
    key = [current_position, target_position]
    if @paths.has_key?(key)
      return @paths[key]
    else
      mh = MinHeap.new
      mh << Element.new(0, current_position, target_position, [])

      possible_paths = []
      loop do
        elem = mh.min!

        break if !elem

        cost, current_position, target_position, input = elem.get_values
        curr_x, curr_y = current_position

        if current_position == target_position
          possible_paths.append(input)
          next
        end

        reasonable_directions = get_reasonable_directions(current_position, target_position)
        reasonable_directions.each do |direction|
          next_position = get_next_position(direction, current_position)

          next_x, next_y = next_position
          next if keypad[next_y][next_y] == '.' # irrecoverable error

          next_input = input.dup.append(direction)

          mh << Element.new(cost + 1, next_position, target_position, next_input)
        end

      end

      @paths[key] = possible_paths
      return possible_paths
    end
  end
end

def solve(keypad, required_output)
  current_position = get_char_pos(keypad, 'A')
  target_position = get_char_pos(keypad, required_output[0])

  cache = $caches[keypad]

  parts = []
  loop do
    possible_paths = cache.get_possible_paths(keypad, current_position, target_position)
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

$caches = {}
$caches[numpad] = Paths.new
$caches[keypad] = Paths.new

required_outputs_from_file.each do |required_output|
  p required_output
  outputs = solve(numpad, required_output)

  2.times do |nb|
    outputs.each do |required_output|
      outputs = solve(keypad, required_output)
      exit
    end
  end
end
