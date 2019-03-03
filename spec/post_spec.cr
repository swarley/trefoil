require "./spec_helper"

post_json = load_json("post.json")

describe Trefoil::PostInfo do
  it "loads a post data structure from json" do
    post_info = Trefoil::PostInfo.from_json(post_json)
    post_info.no.should eq 185314503
  end
end

describe Trefoil::Post do
  client = Trefoil::Client.new
  board = Trefoil::Board.new(client, "a")
  image_post_info = Trefoil::PostInfo.from_json(post_json)
  text_post_info = Trefoil::PostInfo.from_json(load_json("text_post.json"))
  image_post = Trefoil::Post.new(client, board, image_post_info)
  text_post = Trefoil::Post.new(client, board, text_post_info)

  describe "#image?" do
    it "should return true if there is an image" do
      image_post.image?.should be_true
    end

    it "should return false is there is not an image" do
      text_post.image?.should be_false
    end
  end

  describe "#image" do
    it "should return an Image if there is an image available" do
      image_post.image.should be_a(Trefoil::Image)
    end

    it "should return nil if there is no image" do
      text_post.image.should be_nil
    end
  end
end
