# frozen_string_literal: true

class OutOfBounds < StandardError
end

class XmasFinder
  def initialize(puzzle)
    @puzzle = puzzle
  end

  def get_elem(y, x)
    raise OutOfBounds if (x.negative? || y.negative?) ||
                         (y > @puzzle.length - 1) || (x > @puzzle[0].length - 1)

    @puzzle[y][x]
  end

  def diagonal_right_up(x, y)
    if get_elem(y, x) == 'M' && get_elem(y - 1, x + 1) == 'A' && get_elem(y - 2, x + 2) == 'S'
      return y - 1, x + 1
    end
  end

  def diagonal_right_down(x, y)
    if get_elem(y, x) == 'M' && get_elem(y + 1, x + 1) == 'A' && get_elem(y + 2, x + 2) == 'S'
      return y + 1, x + 1
    end
  end

  def diagonal_left_up(x, y)
    if get_elem(y, x) == 'M' && get_elem(y - 1, x - 1) == 'A' && get_elem(y - 2, x - 2) == 'S'
      return y - 1, x - 1
    end
  end

  def diagonal_left_down(x, y)
    if get_elem(y, x) == 'M' && get_elem(y + 1, x - 1) == 'A' && get_elem(y + 2, x - 2) == 'S'
      return y + 1, x - 1
    end
  end
end

finders = %i[diagonal_right_up diagonal_right_down diagonal_left_up diagonal_left_down]

puzzle = nil
File.open(ARGV[0], 'r') do |f|
  puzzle = f.readlines chomp: true
end

xmas_finder = XmasFinder.new(puzzle)
letter_a_locations = []
puzzle.each.with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == 'M'
      finders.each do |method_name|
        location_of_letter_a = xmas_finder.send(method_name, x, y)
        if location_of_letter_a
          letter_a_locations.append(location_of_letter_a)
        end
      rescue OutOfBounds
      end
    end
  end
end

total = 0
letter_a_locations.tally().each_pair do |coord, nb_of_mas|
  total += 1 if nb_of_mas >= 2
end

puts total
