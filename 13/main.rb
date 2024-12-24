require "bigdecimal/util"

class Machine
  attr_accessor :a, :b, :prize
  def initialize(a, b, prize)
    @a = a
    @b = b
    @prize = prize
  end
end

class Button
  attr_accessor :x_increase, :y_increase
  def initialize(button_str)
    @x_increase, @y_increase = button_str.split(',').map(&:strip).map {|elem| elem[2..-1].to_f}
  end
end

def parse_machines(lines)
  machines = []
  button_a = nil
  button_b = nil
  prize_coords = nil
  lines.each.with_index do |line, nb|
    if line == ""
      machines.append(Machine.new(button_a, button_b, prize_coords))
      button_a = nil
      button_b = nil
      prize_coords = nil
    else
      key, value = line.split(":").map(&:strip)
      if key == 'Button A'
        button_a = Button.new(value)
      elsif key == 'Button B'
        button_b = Button.new(value)
      elsif key == 'Prize'
        target_x, target_y = value.split(",").map(&:strip).map {|elem| elem[2..-1].to_f}
        #prize_coords = [target_x, target_y]
        prize_coords = [target_x + 10000000000000, target_y + 10000000000000]
      end
    end
  end

  machines.append(Machine.new(button_a, button_b, prize_coords))

  machines
end

def calculate_min_tokens(machine)
  target_x, target_y = machine.prize
  ma = machine.a
  mb = machine.b

  # Solve using linear algebra. Worked it out using https://www.mathpapa.com/algebra-calculator.html
  a = ma.x_increase
  b = mb.x_increase
  c = ma.y_increase
  d = mb.y_increase
  j = target_x
  k = target_y

  # Black magic:
  y = ((a*k)-(c*j))/((a*d)-(b*c))
  x = (-(b*y)+j)/a

  is_valid = (y % 1 == 0) && (x % 1 == 0)
  if is_valid
    return x * 3 + y * 1
  end
end

lines = IO.readlines(ARGV[0]).map(&:strip)

machines = parse_machines(lines)
total = 0
machines.each do |machine|
  min_tokens = calculate_min_tokens(machine)
  total += min_tokens if min_tokens
end

puts total

