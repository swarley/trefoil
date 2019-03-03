require "../src/trefoil"

client = Trefoil::Client.new

boards = client.boards

def get_board_name(boards)
  print "Board: "
  board_name = gets

  unless boards[board_name]?
    puts "Invalid board name!"
    puts "Available boards: "
    boards.keys.each { |board| puts "\t- #{board}" }
    exit
  end

  return board_name
end

def get_search_string
  print "Search String: "
  gets
end

board_name = get_board_name(boards).as(String)
search_string = get_search_string.as(String)
search_regexp = Regex.new(search_string)

catalog = client.board(board_name).catalog

results_com = catalog.select do |thread|
  next unless thread.op

  op = thread.op.as(Trefoil::Post)
  op.info.com.as(String) =~ search_regexp if op.info.com
end

results_sub = catalog.select do |thread|
  next unless thread.op

  op = thread.op.as(Trefoil::Post)
  op.info.sub.as(String) =~ search_regexp if op.info.sub
end

p (results_com | results_sub).map { |thread| thread.op.as(Trefoil::Post).info.sub }
