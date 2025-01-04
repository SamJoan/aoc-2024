# frozen_string_literal: true

class Program
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
    @out.join(',')
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

  def bxc(_operand)
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

program = parse_input(ARGV[0])
program.execute

puts program.get_output
