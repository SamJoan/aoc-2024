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

def generate_index(disk)
  """
  Allows for o(1) querying, similar to a DB index for a query like below:

  SELECT * FROM spaces WHERE BLOCK_LEN > LEN ORDER BY LEFT_OFFSET

  If you have a block with len 3, you can call index_greater_than[3] and you will get all blocks with len > 3 that you can use.
  """
  index_greater_than = {}
  (0..9).each do |nb|
    index_greater_than[nb] = []
  end

  left_pointer = 0
  parsing_nil = false
  parsing_nil_len = 0
  while left_pointer < disk.length
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
      start = left_pointer - parsing_nil_len

      greater_than = (1..parsing_nil_len)
      greater_than.each do |gt|
        index_greater_than[gt].append([start, parsing_nil_len])
      end

      parsing_nil = false
      parsing_nil_len = 0
    end

    left_pointer += 1
  end

  return index_greater_than
end

def index_delete(index_greater_than, nil_start, nil_len)
  (1..nil_len).each do |nb|
    index_greater_than[nb].delete_if {|index| index[0] == nil_start && index[1] == nil_len }
  end
end

def index_put(index_greater_than, nil_start, nil_len)
  (1..nil_len).each do |nb|
    index_greater_than[nb].each.with_index do |index, i|
      if nil_start < index[0]
        index_greater_than[nb].insert(i, [nil_start, nil_len])
        break
      end
    end
  end
end

def move_block_left(disk, index_greater_than, block_start, block_len, end_pointer)
  nil_start, nil_len = index_greater_than[block_len][0]

  if nil_start == nil || nil_start > end_pointer
    return
  end

  (nil_start..nil_start+block_len-1).each do |i|
    disk[i] = disk[block_start]
  end

  (block_start..block_start+block_len-1).each do |i|
    disk[i] = nil
  end

  index_delete(index_greater_than, nil_start, nil_len)
  if block_len != nil_len
    new_nil_start = nil_start + block_len
    new_nil_length = nil_len - block_len
    index_put(index_greater_than, new_nil_start, new_nil_length)
  end
end

def defragment(disk)
  #puts disk.map {|elem| elem == nil ? '.' : elem }.join
  index_greater_than = generate_index(disk)

  end_pointer = disk.length
  currently_parsing = nil
  currently_parsing_len = 0
  last_moved_block_nb = nil
  while end_pointer > 0
    puts end_pointer if end_pointer % 100 == 0
    end_pointer -= 1
    number = disk[end_pointer]

    if number != nil && !currently_parsing
      currently_parsing = number
      currently_parsing_len += 1
    elsif currently_parsing && number == currently_parsing
      currently_parsing_len += 1
    elsif currently_parsing
      block_start = end_pointer+1
      block_len = currently_parsing_len
      
      already_moved = last_moved_block_nb && disk[block_start] >= last_moved_block_nb
      if !already_moved
        p "parsing: #{disk[block_start]}"
        last_moved_block_nb = disk[block_start]
        move_block_left(disk, index_greater_than, block_start, block_len, end_pointer)
	#puts disk.map {|elem| elem == nil ? '.' : elem }.join
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
#puts disk.map {|elem| elem == nil ? '.' : elem }.join
checksum = checksum(disk)

puts checksum
