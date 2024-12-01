

left = []
right = []
File.open(ARGV[0], "r") do |f|
  f.each_line do |line|
    splat = line.split(" ")
    left.append(splat[0].to_i)
    right.append(splat[1].to_i)
  end
end

left = left.sort()
right = right.sort()

total = 0
left.each_index do |i|
  l = left[i]
  r = right[i]

  nb = l - r
  total += nb.abs
end

puts total
