def convert_to_numeric(keys_or_locks)
  is_keys = keys_or_locks[0][0] == "#####"
  if !is_keys
    new_keys_or_locks = []
    keys_or_locks.each do |lock|
      new_lock = []
      lock.reverse_each do |line|
        new_lock << line
      end

      new_keys_or_locks << new_lock
    end

    keys_or_locks = new_keys_or_locks
  end

  new_array = []
  keys_or_locks.each do |key|
    numbers = []
    key[0].each_char.with_index do |line, x|
      depth_number = 0
      (1..6).each do |nb|
        char = key[nb][x]
        if char != '#'
          numbers.append(depth_number)
          break
        end

        depth_number += 1
      end
    end
    new_array.append(numbers)
  end

  new_array
end


def parse_keys(filename)
  keys = []
  locks = []

  first_line = true
  parsing_key = false
  parsing_lock = false
  key = nil
  lock = nil
  IO.readlines(filename).map(&:strip).each do |line|
    if !parsing_key && !parsing_lock
      if line.include?('#')
        parsing_key = true
        key = [line]
      else
        parsing_lock = true
        lock = [line]
      end
    elsif line == ""
      keys << key if key != nil
      locks << lock if lock != nil

      parsing_key = false
      parsing_lock = false
      key = nil
      lock = nil
    elsif parsing_key
      key << line
    elsif parsing_lock
      lock << line
    end
  end

  keys << key if key != nil
  locks << lock if lock != nil

  keys = convert_to_numeric(keys)
  locks = convert_to_numeric(locks)

  return keys, locks
end

keys, locks = parse_keys(ARGV[0])

valid_keys = 0
keys.each do |key|
  locks.each do |lock|
    overlap = false
    key.each.with_index do |k_digit, nb|
      l_digit = lock[nb]
      sum = k_digit + l_digit
      overlap = true if sum >= 6
    end

    if !overlap
      valid_keys += 1
    end
  end
end

p valid_keys
