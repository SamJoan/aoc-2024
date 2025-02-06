class PseudoRandom
  attr_accessor :secret_number

  def initialize(secret_number)
    @secret_number = secret_number
    @first_run = true
  end

  def next_result
    if @first_run
      @first_run = false
      return @secret_number
    end

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

class MonkeyBananas

  attr_accessor :monkey_bananas

  def initialize(generators)
    @monkey_bananas = {}

    generators.each {|g| add_generator(g) }
  end

  def add_generator(generator)
    last_four = []
    last_result = -1

    first_by_key = {}

    2000.times do |nb|
      bananas_for_sale = generator.next_result % 10

      if last_result != -1
        delta = bananas_for_sale - last_result
        last_four.shift if last_four.length == 4
        last_four.append(delta)

        if last_four.length == 4
          key = last_four.join(',')

          if !first_by_key[key]
            first_by_key[key] = bananas_for_sale
          end
        end
      end

      last_result = bananas_for_sale
    end

    first_by_key.each do |k, v|
      @monkey_bananas[k] = 0 if !@monkey_bananas[k]
      @monkey_bananas[k] += v
    end
  end

  def max
    @monkey_bananas.max_by { |k, v| v }
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

monkey_bananas = MonkeyBananas.new(generators)

p monkey_bananas.max

