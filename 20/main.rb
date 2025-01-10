require "algorithms"
include Containers

DIRECTIONS = [:up, :down, :left, :right]

class Element
  attr_accessor :cost

  def to_s
    "<Element #{@cost} #{@position[0]},#{@position[1]}>"
  end

  def initialize(cost, position, last_direction, cheats_remaining, remaining_cheat_seconds, steps)
    @cost = cost
    @position = position
    @last_direction = last_direction
    @cheats_remaining = cheats_remaining
    @remaining_cheat_seconds = remaining_cheat_seconds
    @steps = steps
  end

  def get_values
    return @cost, @position, @last_direction, @cheats_remaining, @remaining_cheat_seconds, @steps
  end
end

def parse_map(filename)
  start_location = nil
  end_location = nil
  map = []
  IO.readlines(filename).map(&:strip).each.with_index do |line, y|
    start_index = line.index("S")
    end_index = line.index("E")

    if start_index
      start_location = [start_index, y]
      line[start_index] = '.'
    end

    if end_index
      end_location = [end_index, y]
      line[end_index] = '.'
    end

    map.append(line)
  end

  start_location.freeze
  end_location.freeze
  map.freeze

  return start_location, end_location, map
end

def debug_map(map, steps)
  map.each.with_index do |line, y|
    line = line.dup()
    steps.each do |s|
      s_x, s_y = s
      if s_y == y
        line[s_x] = 'X'
      end
    end

    puts line
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

def opposite(direction)
  if direction == :left
    return :right
  elsif direction == :right
    return :left
  elsif direction == :up
    return :down
  elsif direction == :down
    return :up
  else
    raise "Unknown direction #{direction}"
  end
end

def navigate(map, cache, target_location, start_location, original_cost, original_steps, cheating_allowed)
  
  mh = MinHeap.new { |x, y| (x.cost <=> y.cost) == -1 }
  mh.push(0, Element.new(0, start_location, nil, 1, -1, []))

  solutions = []
  loops = 0
  loop do
    loops += 1

    elem = mh.min!

    break if !elem

    cost, location, last_direction, cheats_remaining, remaining_cheat_seconds, steps = elem.get_values
    
    break if original_cost && cost >= original_cost

    #puts "Cost #{cost} elem #{elem}" if loops != 0 && loops % 10000 == 0
    #x, y = location
    #puts "At non-# #{map[y][x]}: #{x} #{y} #{cheats_remaining} #{remaining_cheat_seconds}" if map[y][x] != '#'

    directions = DIRECTIONS.dup
    directions = directions - [opposite(last_direction)] if last_direction

    steps = steps.dup
    steps.append(location)

    if location == target_location
      solutions.append(cost)
      if !original_cost
        original_steps = steps
      end

      next
    end

    if original_cost && cheats_remaining == 0 && remaining_cheat_seconds == 0
      pos = original_steps.index(location)
      remaining_cost = original_cost - pos
      raise "Invalid step" if !pos
      new_total_cost = cost + remaining_cost
      solutions.append(new_total_cost) if new_total_cost < original_cost

      puts new_total_cost
      debug_map(map, steps)
      $stdin.gets
      next
    end

    is_cheating = !remaining_cheat_seconds.negative?
    directions.each do |direction|
      next_pos = step(map, location, direction)
      new_remaining_cheat_seconds = remaining_cheat_seconds - 1

      next if !next_pos

      next_x, next_y = next_pos
      if map[next_y][next_x] != '#'
        mh.push(cost + 1, Element.new(cost + 1, next_pos, direction, cheats_remaining, 0, steps))
      elsif cheating_allowed
        if !is_cheating
          if cheats_remaining > 0
            new_cheats_remaining = cheats_remaining - 1
            new_remaining_cheat_seconds = 19
            mh.push(cost + 1, Element.new(cost + 1, next_pos, direction, new_cheats_remaining, new_remaining_cheat_seconds, steps))
          end
        else
          if new_remaining_cheat_seconds > 0
            mh.push(cost + 1, Element.new(cost + 1, next_pos, direction, cheats_remaining, new_remaining_cheat_seconds, steps))
          else
            # Segfault
          end
        end
      end
    end
  end

  solutions.select! do |cost|
    if !original_cost
      puts "Original cost #{cost}"
      next(true)
    elsif original_cost - cost >= 100 || original_cost < 100
      next(true)
    else
      puts "Found solution, but does not save 100 steps. #{cost} steps :("
      next(false)
    end
  end

  return solutions, original_steps
end

start_location, target_location, map = parse_map(ARGV[0])

cache = {}
solutions, original_steps = navigate(map, cache, target_location, start_location, nil, nil, false)
original_cost = solutions[0]
solutions, _ = navigate(map, cache, target_location, start_location, original_cost, original_steps, true)

#p solutions.map {|s| original_cost - s }.tally

#puts "Total count: #{solutions.length}"
