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

  def horizontal_right(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y, x+1) == "M" && get_elem(y, x+2) == "A" && get_elem(y, x+3) == "S"
  end

  def horizontal_left(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y, x-1) == "M" && get_elem(y, x-2) == "A" && get_elem(y, x-3) == "S"
  end

  def vertical_up(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y-1, x) == "M" && get_elem(y-2, x) == "A" && get_elem(y-3, x) == "S"
  end

  def vertical_down(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y+1, x) == "M" && get_elem(y+2, x) == "A" && get_elem(y+3, x) == "S"
  end

  def diagonal_right_up(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y-1, x+1) == "M" && get_elem(y-2, x+2) == "A" && get_elem(y-3, x+3) == "S"
  end

  def diagonal_right_down(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y+1, x+1) == "M" && get_elem(y+2, x+2) == "A" && get_elem(y+3, x+3) == "S"
  end

  def diagonal_left_up(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y-1, x-1) == "M" && get_elem(y-2, x-2) == "A" && get_elem(y-3, x-3) == "S"
  end

  def diagonal_left_down(puzzle, x, y)
    get_elem(y, x) == "X" && get_elem(y+1, x-1) == "M" && get_elem(y+2, x-2) == "A" && get_elem(y+3, x-3) == "S"
  end
end

finders = [:horizontal_right, :horizontal_left, :vertical_up, :vertical_down, :diagonal_right_up, :diagonal_right_down, :diagonal_left_up, :diagonal_left_down]

puzzle = nil
File.open(ARGV[0], 'r') do |f|
  puzzle = f.readlines chomp:true
end

total = 0
xmas_finder = XmasFinder.new(puzzle)
puzzle.each.with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == 'X'
      finders.each do |method_name|
        begin
	  if xmas_finder.send(method_name, puzzle, x, y)
	    total += 1 
	  end
        rescue OutOfBounds; end
      end
    end
  end
end

puts total
