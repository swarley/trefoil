module Trefoil
  struct Image
    CDN_URL = "https://i.4cdn.org/"

    def self.from_post(post : Post) : Image | Nil
      info = post.info
      return nil if info.filename.nil?

      Image.new(
        info.w.as(Int32),
        info.h.as(Int32),
        info.tn_w.as(Int32),
        info.tn_h.as(Int32),
        info.md5.as(String),
        info.fsize.as(Int32),
        info.ext.as(String),
        info.filename.as(String),
        info.tim.as(Int32),
        post.board.name
      )
    end

    getter width : Int32
    getter height : Int32
    getter thumbnail_width : Int32
    getter thumbnail_height : Int32
    getter md5 : String
    getter fsize : Int32
    getter ext : String
    getter filename : String
    getter tim : Int32
    getter board : String

    def initialize(@width, @height, @thumbnail_width, @thumbnail_height, @md5, @fsize, @ext, @filename, @tim, @board)
    end

    def thumbnail_url
      CDN_URL + "#{board}/#{tim}s#{ext}"
    end

    def url
      CDN_URL + "#{board}/#{tim}#{ext}"
    end
  end
end
