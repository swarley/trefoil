require "json"

require "./board"
require "./client"
require "./image"

module Trefoil
  module Converters
    module IntToBool
      def self.from_json(pull : JSON::PullParser)
        pull.read_int == 1
      end
    end

    module UnixTime
      def self.from_json(pull : JSON::PullParser)
        Time.unix(pull.read_int)
      end
    end

    module DateTime
      def self.from_json(pull : JSON::PullParser)
        time_str = pull.read_string
        # Times are EST/EDT based
        format = "%D(%a)%H:%M"
        format += ":%S" if time_str.size > 18

        Time.parse(time_str, format, Time::Location.load("America/New_York"))
      end
    end
  end

  struct PostInfo
    include JSON::Serializable

    getter no : Int32
    getter resto : Int32

    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter sticky : Bool = false
    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter closed : Bool = false
    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter archived : Bool = false

    @[JSON::Field(converter: Trefoil::Converters::UnixTime)]
    getter archived_on : Time?
    @[JSON::Field(converter: Trefoil::Converters::DateTime)]
    getter now : Time
    @[JSON::Field(converter: Trefoil::Converters::UnixTime)]
    getter time : Time

    getter name : String?
    getter trip : String?
    getter id : String?
    getter capcode : String?
    getter country : String?
    getter country_name : String?
    getter sub : String?
    getter com : String?
    getter tim : Int32?
    getter filename : String?
    getter ext : String?
    getter fsize : Int32?
    getter md5 : String?
    getter w : Int32?
    getter h : Int32?
    getter tn_w : Int32?
    getter tn_h : Int32?

    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter filedeleted : Bool?
    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter spoiler : Bool?

    getter custom_spoilers : Int32?
    getter omitted_posts : Int32?
    getter omitted_images : Int32?
    getter replies : Int32?
    getter images : Int32?

    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter bumplimit : Bool = false
    @[JSON::Field(converter: Trefoil::Converters::IntToBool)]
    getter imagelimit : Bool = false

    getter capcode_replies : Hash(String, Array(Int32))?

    @[JSON::Field(converter: Trefoil::Converters::UnixTime)]
    getter last_modified : Time?

    getter tag : String?
    getter semantic_url : String?
    getter since4pass : Int32?

    getter last_replies : Array(PostInfo)?
  end

  struct Post
    getter info
    getter board

    def initialize(@client : Trefoil::Client, @board : Board, @info : PostInfo)
      if @info.filename
        @image = Trefoil::Image.from_post(self)
      end
    end

    def image : Trefoil::Image | Nil
      return Trefoil::Image.from_post(self) if @info.filename
      nil
    end

    def image? : Bool
      !@info.filename.nil?
    end
  end
end
