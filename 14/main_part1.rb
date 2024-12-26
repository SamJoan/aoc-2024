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


width = ARGV[0].to_i
height = ARGV[1].to_i
robots = parse_positions(ARGV[2])

final_positions = move(100, width, height, robots)
quartiles = [
  # [[valid_x_values], [valid_y_values], [...]]
  [[0, width/2-1], [0, height/2 - 1]], 
              [[width/2+1, width - 1], [0, height / 2 - 1]],

  [[0, width/2-1], [height / 2 + 1, height - 1]],
              [[width/2+1, width - 1], [height / 2 + 1, height - 1]],
]


final_score = 1
quartiles.each do |quartile|
  
  quartile_score = 0
  final_positions.each do |final_position|
    quartile_score += 1 if position_in_quartile(quartile, final_position)
  end

  puts quartile_score

  final_score *= quartile_score
end

puts final_score


