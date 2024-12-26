class Robot
  attr_accessor :position, :velocity

  def initialize(position, velocity)
    @position = position
    @velocity = velocity
  end

end

def parse_positions(filename)
  robots = []
  IO.readlines(filename).each(&:strip).each do |line|
    position_str, velocity_str = line.split(' ').map {|elem| elem[2..-1]}
    position = position_str.split(',').map(&:to_i)
    velocity = velocity_str.split(',').map(&:to_i)

    robots.append(Robot.new(position, velocity))
  end

  robots
end

def move(seconds, width, height, robots)
  final_positions = []
  robots.each do |robot|
    position_x, position_y = robot.position
    velocity_x, velocity_y = robot.velocity

    final_position_x = (position_x + (velocity_x * seconds)) % width
    final_position_y = (position_y + (velocity_y * seconds)) % height
    final_positions.append([final_position_x, final_position_y])
  end

  final_positions
end

def position_in_quartile(quartile, final_position)
  x, y =  final_position
  allowed_x_min, allowed_x_max = quartile[0]
  allowed_y_min, allowed_y_max = quartile[1]

  return x >= allowed_x_min && x <= allowed_x_max &&
    y >= allowed_y_min && y <= allowed_y_max
end

def is_christmas_tree?(nb, width, height, final_positions)
  map = {}
  0.upto(height - 1) do |y|
    map[y] = []
    0.upto(width - 1) do |x|
      map[y].append(0)
    end
  end

  final_positions.each do |final_position|
    x, y = final_position
    map[y][x] += 1
  end

  # Evil.
  if nb % 101 == 74 && nb % 103 == 19

    map.each do |i, row|
      puts row.join('').tr('0', '.')
    end

    puts nb % 74
    puts nb % 101
    puts nb % 103

    puts nb
    $stdin.gets
  end
end


width = ARGV[0].to_i
height = ARGV[1].to_i
robots = parse_positions(ARGV[2])

0.upto(100000) do |nb|
  if nb != 0 && nb % 1000 == 0
    puts nb
  end
  final_positions = move(nb, width, height, robots)
  is_christmas_tree?(nb, width, height, final_positions)
end


