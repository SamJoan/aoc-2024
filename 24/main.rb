class InvalidCalc < StandardError
end

class Gate
  attr_accessor :a_name, :b_name, :solved, :result

  def initialize(a_name, b_name, gate_type)
    @a_name = a_name
    @b_name = b_name
    @gate_type = gate_type
    @solved = false
    @result = nil
  end

  def solve!(values)
    a_value = values[@a_name]
    b_value = values[@b_name]

    return false if a_value == nil || b_value == nil

    @result = case
      when @gate_type == "AND"
        a_value && b_value
      when @gate_type == "OR"
        a_value || b_value
      when @gate_type == "XOR"
        a_value ^ b_value
      else
        raise "Unknown gate type #{@gate_type}"
    end
    
    @solved = true

    return true
  end
end

def parse_gates(filename)
  parsing_inputs = true
  adjacency_tree = {}
  initial_values = {}
  IO.readlines(filename).map(&:strip).each do |line|
    if line == ""
      parsing_inputs = false
      next
    end
    
    if parsing_inputs
      initial_value_name, initial_value_str = line.split(':').map(&:strip)
      raise if initial_value_str != '1' && initial_value_str != '0'
      initial_value = initial_value_str == "1" ? true : false

      raise if initial_values[initial_value_name]
      initial_values[initial_value_name] = initial_value
    else
      a_name, gate_type, b_name, _, result_name = line.split(' ')

      adjacency_tree[result_name] = [] if !adjacency_tree[result_name]
      adjacency_tree[result_name] <<  Gate.new(a_name, b_name, gate_type)
    end
  end

  return adjacency_tree, initial_values
end

def solve(adjacency_tree, values)
  # XXX: Instead of looping, proper adjancency tree recursion would be better.
  loop do
    nb_solved = 0

    adjacency_tree.each do |result_name, gates|
      gates.each do |gate|
        if gate.solve!(values)
          nb_solved += 1
          values[result_name] = gate.result
        end
      end
    end

    #puts "nb_solved: #{nb_solved}"
    break if nb_solved == adjacency_tree.length
  end

  output = {}
  values.filter { |k, value| k.start_with? "z" }.each do |k, v|
    new_key = k[1..].to_i
    output[new_key] = v
  end

  output
end

def produce_number(outputs)
  binary_digits = []
  outputs.sort.each do |k, v|
    binary_digits.prepend(v)
    #exit 1
  end

  binary_digits.map { |v| v ? "1" : "0" }.join.to_i(2)
end

def gates_get()
  adjacency_tree, initial_values = parse_gates(ARGV[0])
  #outputs = solve(adjacency_tree, initial_values)
  #number = produce_number(outputs)

  return adjacency_tree, initial_values
end

def get_base_values()
  base = {}
  45.times do |nb|
    number_s = nb.to_s.rjust(2, "0")
    base["x" + number_s] = false
    base["y" + number_s] = false
  end

  base
end

def valid?(x, y, curr_z_val, next_z_val)
  if x && y
    raise InvalidCalc if curr_z_val != false
    raise InvalidCalc if next_z_val != true
  elsif x || y
    raise InvalidCalc if curr_z_val != true
    raise InvalidCalc if next_z_val != false
  elsif !x && !y
    raise InvalidCalc if curr_z_val != false
    raise InvalidCalc if next_z_val != false
  else
    raise "What?!"
  end
end

def get_faulty_offsets()
  45.times do |nb|
    permutations = [
      [false, true],
      [true, false],
      [false, false],
      [true, true]
    ]

    number_s = nb.to_s.rjust(2, "0")
    base_values = get_base_values()
    permutations.each do |perm|
      initial_values = base_values.dup

      x, y = perm
      initial_values["x"+number_s] = x
      initial_values["y"+number_s] = y
      adjacency_tree, _ = gates_get()
      outputs = solve(adjacency_tree, initial_values)
      #p outputs

      begin
        curr_z = nb
        next_z = nb + 1
        valid = valid?(x, y, outputs[curr_z], outputs[next_z])
      rescue InvalidCalc
        puts "Invalid at offset #{number_s}: x=#{x} y=#{y}. #{curr_z} = #{outputs[curr_z]}, #{next_z} = #{outputs[next_z]}"
        #exit
      end

      #p initial_values
      #$stdin.gets
      #p
    end

  end
end

def find_bad_gates

#faulty_offsets = get_faulty_offsets
faulty_offsets = find_bad_gates

#46.times do |nb|
  #puts "z#{nb}: #{adjacency_tree['z'+()]}"
#end

#p adjacency_tree['rbs']
