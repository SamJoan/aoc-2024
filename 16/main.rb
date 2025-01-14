
# No priority queue in Ruby I guess?
class Element

  attr_accessor :cost, :location

  def initialize(cost, location, direction, path)
    @cost = cost
    @location = location
    @direction = direction
    @path = path
  end

  def get_values
    return @cost, @location, @direction, @path
  end

end

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

  def get_min
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



def parse_map(filename)
  start_location = nil
  map = []
  IO.readlines(filename).map(&:strip).each.with_index do |line, y|
    start_location_x = line.index('S')
    start_location = [start_location_x, y] if start_location_x

    map.append(line)
  end

  return map, start_location
end

def move(map, location, direction)
  next_x, next_y = location
  if direction == :right
    next_x += 1
  elsif direction == :left
    next_x -= 1
  elsif direction == :up
    next_y -= 1
  elsif direction == :down
    next_y += 1
  else
    raise "Unknown direction #{direction}"
  end

  return nil if (next_x.negative? || next_x > map[0].length - 1) ||
    (next_y.negative? || next_y > map.length - 1)

  return next_x, next_y
end

def turn_left(direction)
  if direction == :up
    return :left
  elsif direction == :down
    return :right
  elsif direction == :left
    return :down
  elsif direction == :right
    return :up
  else
    raise "Unknown direction #{direction}"
  end
end

def turn_right(direction)
  if direction == :up
    return :right
  elsif direction == :down
    return :left
  elsif direction == :left
    return :up
  elsif direction == :right
    return :down
  else
    raise "Unknown direction #{direction}"
  end
end

def keep_straight(direction)
  direction
end

def debug_map(map, position)
  target_x, target_y = position
  map.each.with_index do |line, y|
    line = line.dup
    line[target_x] = 'X' if target_y == y

    puts line
  end
end

def navigate(map, start_location, direction)
  initial_cost = 0
  mh = MinHeap.new
  new_loc_right = move(map, start_location, :right)
  new_loc_up = move(map, start_location, :up)
  mh << Element.new(1, new_loc_right, :right, [start_location, new_loc_right])
  mh << Element.new(1001, new_loc_up, :up, [start_location, new_loc_up])

  already_visited = {}
  good_seating_locations = []

  min_cost = nil
  while elem = mh.get_min
    cost, location, direction, path = elem.get_values
    x, y = location

    loc_tuple = [location, direction]

    if map[y][x] == "E"
      min_cost = cost
      puts "Found min cost #{cost}, path #{path}"
      good_seating_locations += path
      next
    end

    next if min_cost != nil && cost > min_cost
    next if map[y][x] == "#"
    
    p cost
    already_visited[loc_tuple] = cost

    [:keep_straight, :turn_right, :turn_left].each do |possibility|
      new_direction = send(possibility, direction)
      new_location = move(map, location, new_direction)
      new_cost = possibility == :keep_straight ? cost + 1 : cost + 1001
      new_path = path + [new_location]

      new_loc_tuple = [new_location, new_direction]
      cache = already_visited[new_loc_tuple]

      if !cache || cache >= new_cost
        new_elem = Element.new(new_cost, new_location, new_direction, new_path)
        mh << new_elem
      end
    end
  end

  good_seating_locations.uniq.length
end


map, start_location = parse_map(ARGV[0])
good_seating_locations = navigate(map, start_location, :right)

puts "Good seating locations: #{good_seating_locations}"
