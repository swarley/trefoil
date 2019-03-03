module Trefoil
  struct Image
    CDN_URL = "https://i.4cdn.org/"

    def self.from_post(post : Trefoil::Post) : Image | Nil
      info = post.info
      return nil if info.filename.nil?

      Image.new(
        info.w.as(UInt32),
        info.h.as(UInt32),
        info.tn_w.as(UInt32),
        info.tn_h.as(UInt32),
        info.md5.as(String),
        info.fsize.as(UInt32),
        info.ext.as(String),
        info.filename.as(String),
        info.tim.as(UInt32),
        post.board.name
      )
    end

    getter width : UInt32
    getter height : UInt32
    getter thumbnail_width : UInt32
    getter thumbnail_height : UInt32
    getter md5 : String
    getter fsize : UInt32
    getter ext : String
    getter filename : String
    getter tim : UInt32
    getter board : String

    def initialize(@width, @height, @thumbnail_width, @thumbnail_height, @md5, @fsize, @ext, @filename, @tim, @board)
    end

    def thumbnail_url
      CDN_URL + "#{board}/#{tim}s#{ext}"
    end

    def url
      CDN_URL + "#{board}/#{tim}#{ext}"
    end

    def get
      HTTP::Client.get(url)
    end
  end
end
