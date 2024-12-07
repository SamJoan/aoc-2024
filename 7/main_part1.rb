def is_possibly_true?(expected_result, numbers)
  operators = [:+, :*]
  operator_permutations = operators.repeated_permutation(numbers.length - 1)
  operator_permutations.each do |permutation|
    total = numbers[0]
    permutation.each.with_index do |symbol, i|
      if symbol == :+
        total += numbers[i + 1]
      else
        total *= numbers[i + 1]
      end
    end

    return true if total == expected_result
  end

  return false
end

total = 0
File.open(ARGV[0]) do |f|
  f.each_line do |line|
    result_string, numbers_string = line.strip.split(':')
    result = result_string.to_i
    numbers = numbers_string.split(' ').map(&:to_i)

    if is_possibly_true?(result, numbers)
      total += result
    end
  end
end

puts total
