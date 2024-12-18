def blink(stones)
  new_stones = []
  stones.each do |stone|
    stone_string = stone.to_s
    if stone == 0
      new_stones.append(1)
    elsif stone_string.length.even?
      stone_string.chars.each_slice(stone_string.length / 2) do |part|
        part = part.join
        new_stones.append(part.to_i)
      end
    else
      new_stones.append(stone * 2024)
    end
  end

  return new_stones
end
  

stones = IO.readlines(ARGV[0]).map(&:strip)[0].split(' ').map(&:to_i)

75.times do |n|
  last_length = stones.length
  stones = blink(stones)

  ratio = stones.length.to_f / last_length.to_f

  puts "Blinked #{n} times. I can see #{stones.length} stones :| ratio:#{ratio}"
end

puts stones.length
