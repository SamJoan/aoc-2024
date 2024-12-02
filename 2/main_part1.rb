left = []
right = []

safe_levels = 0
File.open(ARGV[0], "r") do |f|
  f.each_line do |line|
    levels = line.split(' ')

    if levels[1].to_i > levels[0].to_i
      should_be_increasing = true
    else
      should_be_increasing = false
    end

    safe = true
    levels.each_index do |i|
      curr_level = levels[i].to_i
      next_level = levels[i + 1].to_i
      if levels[i + 1]
        diff = next_level - curr_level
        if diff.abs == 0 or diff.abs > 3
          safe = false
          break
        else
          if should_be_increasing && diff < 0
            safe = false
            break
          elsif !should_be_increasing && diff > 0
            safe = false
            break
          end
        end
      end
    end
    
    if safe
      safe_levels += 1
    end
  end
end

puts safe_levels

