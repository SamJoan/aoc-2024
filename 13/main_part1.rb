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
        prize_coords = [target_x, target_y]
      end
    end
  end

  machines.append(Machine.new(button_a, button_b, prize_coords))

  machines
end

def presses_remaining(target_x, target_y, button)
  max_presses_x = target_x / button.x_increase
  max_presses_y = target_y / button.y_increase

  max_presses = max_presses_x < max_presses_y ? max_presses_x : max_presses_y
  max_presses.to_i
end

def calculate_min_tokens(machine)
  target_x, target_y = machine.prize
  a = machine.a
  b = machine.b

  max_presses_a = presses_remaining(target_x, target_y, a)
  min_tokens = nil
  max_presses_a.downto(1).each do |a_button_presses|
    curr_value_x = a_button_presses * a.x_increase
    curr_value_y = a_button_presses * a.y_increase

    remaining_x = target_x - curr_value_x
    remaining_y = target_y - curr_value_y

    divisible_by_b = b.x_increase / remaining_x == b.y_increase / remaining_y

    if divisible_by_b
      remaining_presses = remaining_x / b.x_increase
      final_token_cost = (a_button_presses * 3) + (remaining_presses)

      min_tokens = min_tokens.nil? || final_token_cost < min_tokens ? final_token_cost : min_tokens
    end
  end

  min_tokens
end

lines = IO.readlines(ARGV[0]).map(&:strip)

machines = parse_machines(lines)
total = 0
machines.each do |machine|
  min_tokens = calculate_min_tokens(machine)
  total += min_tokens if min_tokens
end

puts total

