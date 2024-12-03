# frozen_string_literal: true

total = 0
File.open(ARGV[0], 'r') do |f|
  enabled = true
  f.each_line do |line|
    # https://xkcd.com/208/
    matches = line.scan(/(do\(|don't\(|mul\(\d+,\d+\))/)
    matches.each do |m|
      m = m[0]
      if m.start_with?('mul') && enabled
        splat = m.tr('()mul', '').split(',')
        total += splat[0].to_i * splat[1].to_i
      elsif m == 'do('
        enabled = true
      elsif m == "don't("
        enabled = false
      end
    end
  end
end

puts total
