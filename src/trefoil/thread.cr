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
    getter id

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

    def watch(interval : Time::Span, async : Bool = false, &block : Array(Post) -> _)

      if async
        spawn do
          watch_loop(interval, &block)
        end
      else
        watch_loop(interval, &block)
      end
    end

    private def watch_loop(interval : Time::Span, &block : Array(Post) -> _)
      last_update = Time::UNIX_EPOCH
      loop do
        resp = @client.request("/#{@board.name}/thread/#{@id}.json", last_update)
        if resp.status_code == 200
          posts = Deconstructor.from_json(resp.body).posts
          new_posts = posts.map { |post_info| Post.new(@client, @board, post_info) }.select { |post| post.info.time.to_unix >= last_update.to_unix }
          ret = yield(new_posts)
          # Break if the block returns nil
          break if ret.nil?
        end

        last_update = Time.now(Time::Location::UTC)
        sleep interval
      end
    end
  end
end
