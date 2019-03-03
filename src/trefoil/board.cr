require "json"

require "./catalog"

module Trefoil
  struct BoardInfo
    alias Cooldowns = {threads: UInt16, replies: UInt16, images: UInt16}
    include JSON::Serializable

    @[JSON::Field(key: "board")]
    getter name : String
    getter title : String
    getter ws_board : UInt8
    getter pages : UInt8
    getter max_filesize : UInt32
    getter max_webm_filesize : UInt32
    getter max_comment_chars : UInt16
    getter max_webm_duration : UInt16
    getter bump_limit : UInt16
    getter image_limit : UInt16
    getter cooldowns : Cooldowns
    getter meta_description : String
    getter? spoilers : UInt8?
    getter? custom_spoilers : UInt8?
    getter is_archived : UInt8?
  end

  struct Board
    getter info
    getter name

    # TODO: Meta programming to forward relevant methods to @info
    # more cleanly would be nice
    def initialize(@client : Client, @name : String, @info : BoardInfo? = nil)
    end

    def catalog
      threads = [] of Thread
      CatalogResponse.from_json(@client.get(@name + "/catalog.json")).each do |page|
        threads.concat page[:threads].map { |t| Thread.new(@client, self, t) }
      end
      threads
    end

    def thread(id : Int32)
      thread_info = Thread::Deconstructor.from_json(@client.get("#{@name}/thread/#{id}.json"))
      Thread.new(@client, self)
    end

    def threads
    end
  end

  class Client
    @board_cache = {} of String => BoardInfo
    @troll_flags = {} of String => String

    # Creates a new board for making board specific requests
    def board(name : String)
      Board.new(self, name, @board_cache[name]?)
    end

    def boards
      return @board_cache unless @board_cache.empty?
      cache_boards_and_flags
      @board_cache
    end

    def troll_flags
      return @troll_flags unless @troll_flags.empty?
      cache_boards_and_flags
      @troll_flags
    end

    private def cache_boards_and_flags
      pull = JSON::PullParser.new(get("/boards.json"))
      pull.read_object do
        pull.read_array do
          board = BoardInfo.from_json(pull.read_raw)
          @board_cache[board.name] = board
        end
        pull.skip
        @troll_flags = Hash(String, String).from_json(pull.read_raw)
      end
    end
  end
end
