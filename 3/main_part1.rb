# frozen_string_literal: true

total = 0
File.open(ARGV[0], 'r') do |f|
  f.each_line do |line|
    matches = line.scan(/mul\(\d+,\d+\)/)
    matches.each do |m|
      splat = m.tr('()mul', '').split(',')
      total += splat[0].to_i * splat[1].to_i
    end
  end
end

puts total
