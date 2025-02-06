require "set"

def parse_nodes(filename)
  adjacency_list = {}
  IO.readlines(filename).map(&:strip).each do |line|
    a, b = line.split '-'
    adjacency_list[a] = [] if !adjacency_list[a]
    adjacency_list[b] = [] if !adjacency_list[b]
    adjacency_list[a].append(b)
    adjacency_list[b].append(a)
  end

  adjacency_list
end

def find_max_clique(adjacency_list)
  already_processed = Set[]
  sets = Set[]
  adjacency_list.each do |node, neighbours|
    neighbour_pairs = []
    neighbours.each do |neighbour|
      linked_to_lan = adjacency_list[neighbour] & neighbours
      next if linked_to_lan.empty?

      linked_to_lan.each do |linked|
        result = [node, neighbour, linked].sort
        sets.add(result)
      end
    end
  end

  sets
end

adjacency_list = parse_nodes(ARGV[0])
sets = find_sets_of_three(adjacency_list)

total = 0
sets.each do |set|
  has_t = false
  set.each do |elem|
    if elem.start_with?('t')
      has_t = true
      break
    end
  end
  total += 1 if has_t
end

p total
