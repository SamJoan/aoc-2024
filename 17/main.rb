# frozen_string_literal: true

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

def get_diff_indexes(input_a, input_b)
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

program_class = parse_input(ARGV[0])
original_program = program_class.instructions
$frozen_program = Marshal.dump(program_class)

#i = 04536555555555554
base_nb = "6551100000021704" # this was me calculating manually by tweaking
  # with the numbers.
base_nb = "6551100000021704"

puts "New base number output: #{get_output(base_nb).join(',')}"
puts "                        #{original_program.join(',')} (#{original_program.length})"
puts 

base_nb.each_char.with_index do |current_val, index|
  sample_a = modify_char_at_index(base_nb, index, 2)
  sample_b = modify_char_at_index(base_nb, index, 3)
  different_indexes = get_diff_indexes(sample_a, sample_b)
  last_result = nil
  potentially_valid = []
  (0..7).each do |nb|
    output = modify_char_at_index(base_nb, index, nb)
    any_chars_match = false
    different_indexes.each do |diff_index|
      if original_program[diff_index] == output[diff_index]
        any_chars_match = true
      end
    end

    potentially_valid.append(nb) if any_chars_match
  end

  puts "Potentially valid for index #{index}: #{potentially_valid.join(',')} (Modifies #{different_indexes.join(',')})"
end
