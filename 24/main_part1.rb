
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
  gates = {}
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
      gate = Gate.new(a_name, b_name, gate_type)
      gates[result_name] = gate
    end
  end
  return gates, initial_values
end

def solve(gates, values)
  puts "Total gates to solve: #{gates.length}"

  loop do
    nb_solved = 0

    gates.each do |result_name, gate|
      if gate.solve!(values)
        nb_solved += 1
        values[result_name] = gate.result
      end
    end

    puts "nb_solved: #{nb_solved}"
    break if nb_solved == gates.length
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

gates, initial_values = parse_gates(ARGV[0])
outputs = solve(gates, initial_values)
number = produce_number(outputs)

puts "Result #{number}"
