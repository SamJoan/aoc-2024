# frozen_string_literal: true

def is_update_valid?(update, rules)
  rules.each do |rule|
    before, after = rule
    before_pos = update.index(before)
    after_pos = update.index(after)
    
    both_elements_present = before_pos && after_pos

    if both_elements_present && !(before_pos < after_pos)
      return false
    end
  end

  true
end

rules = []
updates = []
File.open(ARGV[0], 'r') do |f|
  parsing_page_numbers = false
  f.each_line do |line|
    if line == "\n"
      parsing_page_numbers = true
      next
    end

    if not parsing_page_numbers
      before, after = line.strip.split('|')
      rules.append([before, after])
    else
      update = line.strip.split(',')
      updates.append(update)
    end
  end
end

total = 0
updates.each do |update|
  if is_update_valid?(update, rules)
    middle_index = (update.length - 1) / 2
    total += update[middle_index].to_i
  end
end

puts total
