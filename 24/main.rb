require "set"

class InvalidCalc < StandardError
end

class Gate
  attr_accessor :a_name, :b_name, :solved, :result, :output, :gate_type

  def initialize(a_name, b_name, gate_type, output)
    @a_name = a_name
    @b_name = b_name
    @gate_type = gate_type
    @solved = false
    @result = nil
    @output = output
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

  def to_s
    return "<#{@a_name} #{@gate_type} #{@b_name} -> #{@output}>"
  end

end

def parse_gates(filename)
  parsing_inputs = true
  adjacency_tree = {}
  initial_values = {}
  input_gates = {}
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
      gate = Gate.new(a_name, b_name, gate_type, result_name)

      input_gates[a_name] = [] if !input_gates[a_name]
      input_gates[a_name] << gate

      input_gates[b_name] = [] if !input_gates[b_name]
      input_gates[b_name] << gate

      adjacency_tree[result_name] = [] if !adjacency_tree[result_name]
      adjacency_tree[result_name] << gate
    end
  end

  return adjacency_tree, input_gates, initial_values
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
  adjacency_tree, input_gates, initial_values = parse_gates(ARGV[0])

  return adjacency_tree, input_gates, initial_values
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

def find_bad_gates()
  adjacency_tree, input_gates, _ = gates_get()

  #45.times do |nb|
    #number_s = nb.to_s.rjust(2, "0")
    #input_gates['x'+number_s].each do |gate|
      #puts "#{gate.to_s} -> #{gate.output} #{input_gates[gate.output]&.map(&:to_s)}"
    #end
    #$stdin.gets
  #end

  seen = Set[]
  bad_gates = []
  46.times do |nb|
    number_s = nb.to_s.rjust(2, "0")
    next_number_s = (nb+1).to_s.rjust(2, "0")
    prev_number_s = (nb-1).to_s.rjust(2, "0")

    cur_neighbours = adjacency_tree["z"+number_s]
    #puts "z#{number_s}:"
    raise if cur_neighbours.length != 1
    
    depth = 0
    loop do
      next_neighbours = []

      if nb > 2 && nb != 45
        if depth == 0
          if cur_neighbours[0].gate_type != 'XOR'
            puts "Bad gate #{cur_neighbours[0].output}"
            bad_gates << cur_neighbours[0]
            cur_neighbours.delete(cur_neighbours[0])
          end
        elsif depth == 1
          found_xor = false
          found_or = false
          cur_neighbours.each do |c|
            if c.gate_type == "XOR"
              found_xor = true
              if !c.a_name == "x"+number_s && !c.b_name == "x"+number_s
                puts "Bad gate at offset #{nb} #{c}"
                bad_gates << c
                cur_neighbours.delete(c)
              end
            elsif c.gate_type == "OR"
              found_or = true
            else
              puts "Bad gate at offset #{nb} #{c}"
              bad_gates << c
              cur_neighbours.delete(c)
            end
          end

          #if !found_xor || !found_or
            #puts "#{nb} at depth #{depth}: Mising OR or XOR"
          #end
        elsif depth == 2
          nb_ands = 0
          found_and_x = false
          cur_neighbours.each do |c|
            if c.gate_type == 'AND'
              nb_ands += 1
              if c.a_name == "x"+prev_number_s || c.b_name == "x"+prev_number_s
                found_and_x = true
              end
            else 
              puts "Bad gate at offset #{nb} #{c}"
              cur_neighbours.delete(c)
              bad_gates << c
            end
          end

          #if nb_ands != 2 || !found_and_x
            #puts "#{nb} at depth #{depth}: Bad nb of AND elems or missing found_and_x"
          #end
        end
      end

      cur_neighbours.each do |cur_neighbour|
        #padding = "  " * depth
        #puts "#{padding}cur: #{cur_neighbour}"

        a_tree = adjacency_tree[cur_neighbour.a_name]
        b_tree = adjacency_tree[cur_neighbour.b_name]

        if depth < 2
          next_neighbours += a_tree if a_tree
          next_neighbours += b_tree if b_tree
        end
      end

      depth += 1
      break if next_neighbours.length == 0

      cur_neighbours = next_neighbours
    end
    #$stdin.gets
  end

  bad_gates
end

#faulty_offsets = get_faulty_offsets
bad_gates = find_bad_gates

p bad_gates.map(&:output).sort.join(',')

#46.times do |nb|
  #puts "z#{nb}: #{adjacency_tree['z'+()]}"
#end

#p adjacency_tree['rbs']
