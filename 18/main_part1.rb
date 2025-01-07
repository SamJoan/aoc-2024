# frozen_string_literal: true

class Element
  attr_accessor :cost

  def initialize(cost, position)
    @cost = cost
    @position = position
  end

  def get_values
    return @cost, @position
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


def generate_memory_map(size)
  memory_map = {}
  (0..size.to_i - 1).each do |y|
    memory_map[y] = []
    (0..size.to_i - 1).each do |x|
      memory_map[y].append('.')
    end
  end

  memory_map
end

def corrupt!(filename, memory_map, kilobytes)
  kb_read = 0
  IO.readlines(filename).map(&:strip).each do |line|
    break if kb_read == kilobytes.to_i
    x, y = line.split(',').map(&:to_i)

    raise "Invalid coords" if (x.negative? || x > memory_map[0].length - 1) ||
      (y.negative? || y > memory_map.length - 1)
    raise "Already was a #" if memory_map[y][x] == '#'
    memory_map[y][x] = '#'
    kb_read += 1
  end
end

def debug_map(memory_map, position=nil)
  target_x, target_y = position
  memory_map.each do |y, line|
    line = line.dup
    if position && target_y == y 
      line[target_x] = 'X'
    end
    puts line.join

    break if target_y && y > (target_y + 30).round(-1)
  end
end

def step(map, current_position, direction)
  next_x, next_y = current_position

  if direction == :up
    next_y -= 1
  elsif direction == :down
    next_y += 1
  elsif direction == :left
    next_x -= 1
  elsif direction == :right
    next_x += 1
  else
    raise "Unknown direction #{direction}"
  end

  return nil if (next_x.negative? || next_x > map[0].length - 1) ||
    (next_y.negative? || next_y > map.length - 1)

  return next_x, next_y
end

def navigate_map(memory_map, start_position)
  mh = MinHeap.new

  target = [memory_map.length - 1, memory_map.length - 1]

  directions = [:up, :down, :left, :right]
  mh << Element.new(1, step(memory_map, start_position, :right))

  next_pos_down = step(memory_map, start_position, :down)
  next_pos_down_x, next_pos_down_y = next_pos_down
  mh << Element.new(1, next_pos_down) if memory_map[next_pos_down_y][next_pos_down_x] != '#'

  already_visited = {}

  loop do
    elem = mh.get_min
    break if !elem

    cost, position = elem.get_values
    key = [position]

    if position == target
      puts "found target with a cost of #{cost}, curr pos = #{position}"
      return true
    end

    #puts "[+] #{cost}: #{position}"
    #debug_map(memory_map, position)
    #$stdin.gets

    directions.each do |direction|
      next_pos = step(memory_map, position, direction)
      next_cost = cost + 1
      next if !next_pos

      next_x, next_y = next_pos
      next if memory_map[next_y][next_x] == '#'

      next_key = [next_pos]
      next if already_visited[next_key]
      already_visited[next_key] = true

      mh << Element.new(next_cost, next_pos)
    end
  end

  return false
end
  

memory_map = generate_memory_map(ARGV[0])
corrupt!(ARGV[1], memory_map, ARGV[2])

debug_map(memory_map)

start_pos = [0, 0]
navigate_map(memory_map, start_pos)
