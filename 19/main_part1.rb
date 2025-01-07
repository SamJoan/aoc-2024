class FoundASolutionException < StandardError; end

def parse_onsen(filename)
  parsing_required_patterns = false
  available_towels = nil
  required_patterns = []
  IO.readlines(filename).map(&:strip).each do |line|
    next if line == ""

    if !available_towels
      available_towels = line.split(',').map(&:strip)
    else
      required_patterns.append(line)
    end
  end

  return available_towels, required_patterns
end

def arrange_towels(required_pattern, available_towels, solution_arr)
  if required_pattern == ""
    raise FoundASolutionException
  end

  nb_solutions = 0
  available_towels.each do |towel|
    next_chunk = required_pattern[0..towel.length - 1]
    if next_chunk == towel
      remaining = required_pattern.dup[towel.length..]
      next_solution = solution_arr.dup
      next_solution.append(towel)
      arrange_towels(remaining, available_towels, next_solution)
    end
  end
end

available_towels, required_patterns = parse_onsen(ARGV[0])
available_towels.freeze

total = 0
processed = 0
required_patterns.each do |required_pattern|
  puts "Processed #{processed} so far"
  begin
    arrange_towels(required_pattern, available_towels, [])
  rescue FoundASolutionException
    total += 1
  end

  processed += 1
end

puts "Found #{total} viable patterns."
