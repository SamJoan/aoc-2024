left = []
right = []
File.open(ARGV[0], "r") do |f|
  f.each_line do |line|
    splat = line.split(" ")
    left.append(splat[0].to_i)
    right.append(splat[1].to_i)
  end
end

right_count = right.tally()

total = 0
left.each_index do |i|
  l = left[i]
  nb_times_in_right = right_count[l]
  if nb_times_in_right
    total += l * nb_times_in_right
  end
end

puts total
