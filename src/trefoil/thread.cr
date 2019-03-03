require "json"
require "./client"
require "./post"

module Trefoil
  struct Thread
    struct Deconstructor
      include JSON::Serializable
      getter posts : Array(Trefoil::PostInfo)
    end

    getter op : Post?

    def initialize(@client : Client, @board : Board, @id : UInt32)
    end

    def initialize(@client : Client, @board : Board, op_info : PostInfo)
      @op = Post.new(@client, @board, op_info)
      @id = op_info.no
    end

    # Returns an array of Post objects from this thread.
    def posts
      post_array = Deconstructor.from_json(@client.get("/#{@board.name}/thread/#{@id}.json")).posts
      post_array.map { |post_info| Post.new(@client, @board, post_info) }
    end

    def watch(update_time, &block)
      # TODO: Must modify Client#get to accept headers so that we can use
      # If-Modified-Since
    end
  end
end
