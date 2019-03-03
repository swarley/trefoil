# trefoil

A crystal interface for the 4chan public REST API.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     trefoil:
       github: swarley/trefoil
   ```

2. Run `shards install`

## Usage

```crystal
require "trefoil"

# Display all images in the first thread on /a/

client = Trefoil::Client.new

client.board("a").catalog.first.posts.each do |post|
  image = post.image
  puts image.url if image
end
```

## Contributing

1. Fork it (<https://github.com/swarley/trefoil/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matt](https://github.com/swarley) - creator and maintainer
