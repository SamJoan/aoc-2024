# frozen_string_literal: true

def are_levels_safe?(levels)
  should_be_increasing = levels[1].to_i > levels[0].to_i

  safe = true
  levels.each_index do |i|
    curr_level = levels[i].to_i
    next_level = levels[i + 1].to_i
    next unless levels[i + 1]

    diff = next_level - curr_level
    if diff.abs.zero? || (diff.abs > 3)
      safe = false
      break
    elsif should_be_increasing && diff.negative?
      safe = false
      break
    elsif !should_be_increasing && diff.positive?
      safe = false
      break
    end
  end

  safe
end

safe_levels = 0
File.open(ARGV[0], 'r') do |f|
  f.each_line do |line|
    levels = line.split(' ')

    safe = are_levels_safe?(levels)
    unless safe
      levels.each_index do |i|
        new_levels = levels.dup
        new_levels.delete_at(i)
        safe = are_levels_safe?(new_levels)
        break if safe
      end
    end

    safe_levels += 1 if safe
  end
end

puts safe_levels
