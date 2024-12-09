def get_char_locations(map)
  chars = {}
  map.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
      if char != '.'
        if !chars[char]
          chars[char] = []
        end
        chars[char].append([x, y])
      end
    end
  end

  chars
end

def debug(map)
  map.each do |line|
    p line
  end
end

def coords_valid?(map, coords)
  x, y = coords
  invalid = (x > map[0].length - 1 || x.negative?) ||
    (y > map.length - 1 || y.negative?)
  
  !invalid
end

def populate_antinodes(map)
  chars = get_char_locations(map)

  chars.each do |char, value|
    pairs = value.combination(2)
    pairs.each do |pair|
      # https://stackoverflow.com/questions/2682411/ruby-sum-corresponding-members-of-two-or-more-arrays
      a, b = pair
      distance = pair.transpose.map {|x| x.reduce(:-)}

      map[a[1]][a[0]] = '#'
      map[b[1]][b[0]] = '#'

      loop do 
        antinode_a = [a[0] + distance[0] , a[1] + distance[1]]
        if coords_valid?(map, antinode_a)
          map[antinode_a[1]][antinode_a[0]] = '#' 
          a = antinode_a
        else
          break
        end
      end

      loop do
        antinode_b = [b[0] - distance[0] , b[1] - distance[1]]
        if coords_valid?(map, antinode_b)
          map[antinode_b[1]][antinode_b[0]] = '#'
          b = antinode_b
        else
          break
        end
      end
    end
  end
end
  

map = IO.readlines(ARGV[0]).map(&:strip)
additional = populate_antinodes(map)

total = 0
map.each do |line|
  total += line.count('#')
end

puts total
