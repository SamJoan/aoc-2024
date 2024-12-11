def generate_disk(dense_format)
  disk = []
  id = 0
  dense_format.each_char.with_index do |char, index|
    parsing_file = !index.odd?
    if parsing_file
      (0..char.to_i - 1).each do
        disk.append(id)
      end

      id += 1
    else
      (0..char.to_i - 1).each do
        disk.append(nil)
      end
    end
  end

  disk
end

def defragment(disk)
  free_pos = 0
  end_pos = disk.length - 1
  until free_pos >= end_pos
    free_char = disk[free_pos]
    if free_char != nil
      free_pos += 1
      next
    else
      end_number = nil
      loop do
        end_number = disk[end_pos]
        break if end_number
        end_pos -= 1
      end

      disk[free_pos] = end_number
      disk[end_pos] = nil
    end
  end
end

def checksum(disk)
  disk.compact.each.with_index.sum do |char, index|
      char.to_i * index
  end
end

dense_format = IO.readlines(ARGV[0])[0].strip

disk = generate_disk(dense_format)
defragment(disk)
checksum = checksum(disk)

puts checksum
