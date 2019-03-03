require "../src/trefoil"

# Display all images in the first thread on /a/

client = Trefoil::Client.new

client.board("a").catalog.first.posts.each do |post|
  image = post.image
  puts image.url if image
end
