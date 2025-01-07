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
  @result ||= Hash.new do |h, key|
    if key == ""
      h[key] = 1
      next
    end

    nb_solutions = 0
    available_towels.each do |towel|
      next_chunk = key[0..towel.length - 1]
      if next_chunk == towel
        remaining = key.dup[towel.length..]
        next_solution = solution_arr.dup
        next_solution.append(towel)
        nb_solutions += arrange_towels(remaining, available_towels, next_solution)
      end
    end

    h[key] = nb_solutions
  end

  a = @result[required_pattern] # why is this needed?
  @result[required_pattern]
end

available_towels, required_patterns = parse_onsen(ARGV[0])
available_towels.freeze

processed = 0
nb_solutions = 0
required_patterns.each do |required_pattern|
  puts "Processed #{processed} so far"
  nb_solutions += arrange_towels(required_pattern, available_towels, [])

  processed += 1
end

puts "Found #{nb_solutions} viable patterns."
