class PseudoRandom
  attr_accessor :secret_number

  def initialize(secret_number)
    @secret_number = secret_number
    @step = 0
  end

  def next_result
    # Step 1
    mix(@secret_number * 64)
    prune

    # Step 2
    mix((@secret_number / 32).floor)
    prune

    # Step 3
    mix(@secret_number * 2048)
    prune

    @secret_number
  end

  def mix(result)
    @secret_number = @secret_number ^ result
  end

  def prune
    @secret_number = @secret_number % 16777216
  end

end

def parse_initial_secret_numbers(filename)
  generators = []
  IO.readlines(filename).map(&:strip).map(&:to_i).each do |secret_number|
    generators << PseudoRandom.new(secret_number)
  end

  generators
end

generators = parse_initial_secret_numbers(ARGV[0])

total = 0
generators.each do |generator|
  2000.times do 
    generator.next_result
  end

  total += generator.secret_number
end


