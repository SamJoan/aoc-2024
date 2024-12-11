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

def move_block_left(disk, end_location, block)
  block_len = block.length
  left_pointer = 0
  parsing_nil = false
  parsing_nil_len = 0
  while left_pointer < end_location
    number = disk[left_pointer]
    
    starting = number == nil && !parsing_nil
    continuing = number == nil
    ending = number != nil && parsing_nil
    if starting
      parsing_nil = true
      parsing_nil_len += 1
    elsif continuing
      parsing_nil_len += 1
    elsif ending
      if parsing_nil_len >= block_len
        start = left_pointer - parsing_nil_len
        (start...start + block_len).each do |write_ptr|
          read_ptr = (end_location + 1) + (write_ptr - start)

          disk[write_ptr] = disk[read_ptr]
          disk[read_ptr] = nil
        end

        #p disk
        #$stdin.gets

        return
      end

      parsing_nil = false
      parsing_nil_len = 0
    end

    left_pointer += 1
  end

  #puts "no space"

end
  

def defragment(disk)
  end_pointer = disk.length
  currently_parsing = nil
  currently_parsing_len = 0
  last_moved_block_nb = nil
  while end_pointer > 0
    puts end_pointer
    end_pointer -= 1
    number = disk[end_pointer]

    if !currently_parsing
      currently_parsing = number
      currently_parsing_len += 1
    elsif currently_parsing && number == currently_parsing
      currently_parsing_len += 1
    else
      block = disk[end_pointer+1..end_pointer+currently_parsing_len]
      if !(last_moved_block_nb && block[0] > last_moved_block_nb)

        #puts "#{number}, last:#{last_moved_block_nb}"
        #puts "Moving block #{block}"
        move_block_left(disk, end_pointer, block)
        last_moved_block_nb = block[0]
      end

      if number == nil
        currently_parsing = nil
        currently_parsing_len = 0
      else
        currently_parsing = number
        currently_parsing_len = 1
      end
    end
  end
end

def checksum(disk)
  disk.each.with_index.sum do |char, index|
      char.to_i * index
  end
end

dense_format = IO.readlines(ARGV[0])[0].strip

disk = generate_disk(dense_format)
defragment(disk)
puts disk.map {|elem| elem == nil ? '.' : elem }.join
checksum = checksum(disk)

puts checksum
