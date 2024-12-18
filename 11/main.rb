
def stones_add(stones_counter, stone, amount)
  stones_counter[stone] = 0 if stones_counter[stone] == nil
  stones_counter[stone] += amount
end

def blink(stones)
  new_stones = {}
  stones.each do |stone, amount|
    stone_string = stone.to_s
    if stone == 0
      stones_add(new_stones, 1, amount)
    elsif stone_string.length.even?
      stone_string.chars.each_slice(stone_string.length / 2) do |part|
        part = part.join
        stones_add(new_stones, part.to_i, amount)
      end
    else
      stones_add(new_stones, stone * 2024, amount)
    end
  end

  return new_stones
end
  

stones = IO.readlines(ARGV[0]).map(&:strip)[0].split(' ').map(&:to_i)
stones_counter = {}
stones.each do |stone|
  stones_add(stones_counter, stone, 1)
end

75.times do |n|
  last_length = stones.length
  stones_counter = blink(stones_counter)
end

puts stones_counter.values.sum
