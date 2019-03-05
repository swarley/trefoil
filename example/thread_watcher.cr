require "../src/trefoil"

client = Trefoil::Client.new

puts "Starting"

# Print to stdout when a new post occurs in the first thread of /a/
thread = client.board("a").catalog.first

puts "Watching thread #{thread.id}"

thread.watch(interval: 15.seconds) do |new_posts|
  puts "New Posts!"
  p (new_posts.map { |post|
    img = post.image
    next nil unless img
    img.url
  })

  if ARGV.includes? "autodie"
    false
  else
    true
  end
end
