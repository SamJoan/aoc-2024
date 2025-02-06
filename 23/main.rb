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

def all_nodes_connected(adjacency_list, number_of_edges, nodes)
  valid = true
  nodes.each do |node|
    linked = adjacency_list[node] & nodes
    if linked.length != number_of_edges - 1
      valid = false
      break
    end
  end

  return valid
end

def find_max_clique(adjacency_list)
  number_of_edges = adjacency_list.first.last.length
  sets = Set[]
  adjacency_list.each do |node, neighbours|
    neighbour_pairs = []
    neighbours.each do |neighbour|
      linked_to_lan = adjacency_list[neighbour] & neighbours
      next if linked_to_lan.empty?

      if linked_to_lan.length == number_of_edges - 2
        result = ([node, neighbour] + linked_to_lan).sort
        sets.add(result)
      end
    end
  end

  sets.each do |result|
    if all_nodes_connected(adjacency_list, number_of_edges, result)
      return result.join(',')
    end
  end

  raise "Can't find appropriate max_clique."
end

adjacency_list = parse_nodes(ARGV[0])
max_clique = find_max_clique(adjacency_list)

puts max_clique
