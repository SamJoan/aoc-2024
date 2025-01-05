# frozen_string_literal: true
class Element

  attr_accessor :cost

  def initialize(cost, base_nb)
    @cost = cost
    @base_nb = base_nb
  end

  def get_values
    return @cost, @base_nb
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



class Program

  attr_accessor :a, :instructions

  NEXT_INSTRUCTION_OFFSET = 2

  INSTRUCTION_TABLE = %i[
    adv
    bxl
    bst
    jnz
    bxc
    out
    bdv
    cdv
  ].freeze

  def initialize(a, b, c, instructions)
    @a = a
    @b = b
    @c = c
    @instructions = instructions
    @iptr = 0
    @out = []
  end

  def execute
    return @out if @iptr > @instructions.length - 1

    opcode = @instructions[@iptr]
    operand = @instructions[@iptr + 1]

    send(Program::INSTRUCTION_TABLE[opcode], operand)
    @iptr += Program::NEXT_INSTRUCTION_OFFSET

    execute
  end

  def get_output
    @out
  end

  private

  def get_combo_value(operand)
    return operand if operand <= 3
    return @a if operand == 4
    return @b if operand == 5
    return @c if operand == 6

    raise "Invalid value of operand #{operand}."
  end

  def adv(operand)
    numerator = @a
    denominator = 2**get_combo_value(operand)

    result = (numerator / denominator).to_i
    @a = result
  end

  def bxl(operand)
    result = @b ^ operand
    @b = result
  end

  def bst(operand)
    result = get_combo_value(operand) % 8
    @b = result
  end

  def jnz(operand)
    return unless @a != 0

    @iptr = operand - Program::NEXT_INSTRUCTION_OFFSET
  end

  def bxc(_)
    result = @b ^ @c
    @b = result
  end

  def out(operand)
    result = get_combo_value(operand) % 8
    @out.append(result)
  end

  def bdv(operand)
    numerator = @a
    denominator = 2**get_combo_value(operand)

    result = (numerator / denominator).to_i
    @b = result
  end

  def cdv(operand)
    numerator = @a
    denominator = 2**get_combo_value(operand)

    result = (numerator / denominator).to_i
    @c = result
  end
end

def parse_input(filename)
  parsing_registers = true
  a, b, c, instructions = nil
  IO.readlines(filename).map(&:strip).each do |line|
    if line == ''
      parsing_registers = false
      next
    end

    key, val = line.split(':')

    if parsing_registers
      val = val.strip.to_i
      case key
      when 'Register A'
        a = val
      when 'Register B'
        b = val
      when 'Register C'
        c = val
      else
        raise "Unknown register #{key}"
      end
    else
      instructions = val.strip.split(',').map(&:to_i)
    end
  end

  Program.new(a, b, c, instructions)
end

def get_diff_indexes(base_nb, index)
  base_value = base_nb[index]
  sample_a = modify_char_at_index(base_nb, index, (base_value.to_i + 1) % 8)
  sample_b = modify_char_at_index(base_nb, index, (base_value.to_i + 2) % 8)

  list_diff(sample_a, sample_b)
end

def list_diff(input_a, input_b)
  different_indexes = []
  input_a.each.with_index do |a, i|
    different_indexes.append(i) if a != input_b[i]
  end

  different_indexes
end

def get_output(base_nb)
  i = base_nb.oct
  program = Marshal.load($frozen_program)
  program.a = i
  program.execute

  program.get_output
end

def modify_char_at_index(base_nb, index, nb)
  new_nb = base_nb.dup

  new_nb[index] = nb.to_s
  i = new_nb.oct

  program = Marshal.load($frozen_program)
  program.a = i
  program.execute

  new_output = program.get_output
  new_output
end

def modify_base_nb(base_nb, index, nb)
  new_nb = base_nb.dup
  new_nb[index] = nb.to_s

  new_nb
end

def calculate_distance(target_result, base_nb)
  output = get_output(base_nb)

  list_diff(output, target_result).length
end

program_class = parse_input(ARGV[0])
original_program = program_class.instructions
$frozen_program = Marshal.dump(program_class)

#i = 04536555555555554
#base_nb = "6551100000021704" # this was me calculating manually by tweaking
  # with the numbers.
#base_nb = "6551100000021704"
initial_base_nb = ARGV[1]

puts "New base number output: #{get_output(initial_base_nb).join(',')}"
puts "                        #{original_program.join(',')} (#{original_program.length})"
puts 

raise "Bad base_nb len" if get_output(initial_base_nb).length != original_program.length
TARGET_OUTPUT = original_program.dup.freeze

mh = MinHeap.new
mh << Element.new(calculate_distance(TARGET_OUTPUT, initial_base_nb), initial_base_nb)

already_seen = {}

min_base_value = nil
loop do
  elem = mh.get_min
  distance, base_nb = elem.get_values

  next if already_seen[base_nb]

  if distance == 0
    puts "Found target value #{base_nb} (oct -> int #{base_nb.oct}). Output of calculation: #{get_output(base_nb)}, target #{TARGET_OUTPUT}"
    if !min_base_value
      min_base_value = base_nb
    else
      if base_nb < min_base_value
        min_base_value = base_nb
        puts "[+] Newest min #{base_nb} (oct -> int #{base_nb.oct}). Output of calculation: #{get_output(base_nb)}, target #{TARGET_OUTPUT}"
      end
    end
  end

  already_seen[base_nb] = true
  #puts "[+] #{distance} #{base_nb}"

  base_output = get_output(base_nb)
  base_nb.each_char.with_index do |current_val, index|
    indexes_that_change = get_diff_indexes(base_nb, index)

    range = index == 0 ? (1..7) : (0..7) 

    range.each do |nb|
      modified_base_nb = modify_base_nb(base_nb, index, nb)
      next if modified_base_nb == base_nb
      next if already_seen[modified_base_nb]

      mh << Element.new(calculate_distance(TARGET_OUTPUT, modified_base_nb), modified_base_nb)
    end

  end
end
